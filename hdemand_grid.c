/**************************************************************/
// arguments
// 1: cons search mode flag
// 2: 1 x 2 vector containing state pair [W,Y]
// 3: NCH x 5 vector with grid of feasible choices for H (for movers)
//    and associated values for prices, service flow, and delta;
//    first row: choice points
//    second: prices
//    third: expected prices
//    four: service flow
//    five: delta      
// 4: MinIndex: lowest index in choice grid at which to start searching
// 5: NSH x 5 vector with grid of state points for H (for stayers)
//    and associated values for prices, exp. prices, service flow, and delta;
//    row order same as above
// 6: 1 x NPARAM vector with scalar parameters to be passed in order
// 7: matrix with stochastic process for innovations to income and housing, RV x NS
//    first row: probabilities
//    second row: innovation to permanent component
//    third: temporary innovation
// 8: matrix with bounds of state variable grids 3 x 3
// 9: 1 x 2 cell array with value functions 
//    first element: mover function, NPmov X 2
//    second element: stayer function, NPstay x 3
// 10: matrix with number of points for each equally-spaced segment, 2 x 3
//
// output
// 1 x 4 cell array with
// first elem: scalar mover value
// second elem: 1 x 3 vector with mover optimal policy: cons, hous quality, bond
// third elem: 1 x NSH vector with stayer values
// fourth elem: 3 x NSH matrix with stayer optimal policies 
/**************************************************************/

#include "mex.h"
#include "matrix.h"
#include <string.h>
#include <math.h>

#define TOL 1e-10
#define MAXBISECT 300
#define SEARCH_MODE_BISECT 0

// *******************************************************
// Global variables

// indices
int NSH; // number of points in H state grid
int NCH; // number of points in H choice grid
int NS; // number of unique exogenous income states
int RV; // number of exogenous shocks


// search mode
int search_mode;

// scalar params to be passed in this order
double hd_gamma;
double rho;
double beta;
double tc;
double psi;
double xi;
double Rf;
double prm;
double dpr;
double g_age;
double lastPeriodVal;

// matrix with exogenous income process
double *process;

// wealth and income state
double W, Y;

// vectors of state and choice grids for house quality
double *SgridH, *CgridH;

// starting search index
int hi_start;

// vectors of prices, service flows and deltas with same length as CgridH
double *Cpvals, *Csvals, *Cdeltavals, *Spvals, *Ssvals, *Sdeltavals;
double *CEpvals, *SEpvals; // vector of expected prices next period (same length as CgridH)

// bounds of state space
double *stateBounds;

// specific globals for interpolated VF case; unused otherwise
// value matrices
double *moverVF, *stayerVF;
// number of grid points for each segment and total
double *numberGridPoints;
int NGPtotal[3];


// *******************************************************
// Prototypes
// init variables
void processArgs(const mxArray *prhs[]);
// value function single evaluation routine
double computeValue (int mv, int hi, double *S, double *x);
// next period's value function evaluation
double evalV1(int mv, double *S);
// bisect consumption interval
double bisect(int mv, double cmax, double cmrest, int hi, double *S, double *x);
// search for optimal consumption on grid
double gridsearch(int mv, int NPS, double cmax, double cmrest, int hi, double *S, double *x);
// next period's value function evaluation based on linear interpolation
double evalV1_interp(int mv, double *S, double *bounds, int *npts, int *npts_offset);
// helper function for matrix lookup
double lookupValue(int mv, int *coord);


// main function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	mxArray *Res, *vmret_m, *vsret_m, *pmret_m, *psret_m, *indexret_m;
	mwSize *ntmp;

	int hi, j, hi_mov;
	double cmax, cnobor;
	double tmp_choice[3], pmov[3], tmp_V, Vmov, Vstay, WT, Stmp[2];
	double *vmret, *vsret, *pmret, *psret, *indexret;



	/* Check for proper number of arguments. */
	if (nrhs != 10) {
		mexErrMsgTxt("Arguments (10) required"); 
	} 

	// init global vars from inputs
	processArgs(prhs);

	// allocate return matrices
	plhs[0] = mxCreateCellMatrix(5,1);
	Res=plhs[0];
	vmret_m=mxCreateDoubleMatrix(1,1, mxREAL );
	vsret_m=mxCreateDoubleMatrix(1,NSH, mxREAL );
	pmret_m=mxCreateDoubleMatrix(1,3, mxREAL );
	psret_m=mxCreateDoubleMatrix(3,NSH, mxREAL );
	indexret_m=mxCreateDoubleMatrix(1,1, mxREAL );
	mxSetCell(Res,0,vmret_m);
	mxSetCell(Res,1,pmret_m);
	mxSetCell(Res,2,vsret_m);
	mxSetCell(Res,3,psret_m);
	mxSetCell(Res,4,indexret_m);

	vmret=mxGetPr(vmret_m);
	vsret=mxGetPr(vsret_m);
	pmret=mxGetPr(pmret_m);
	psret=mxGetPr(psret_m);
	indexret=mxGetPr(indexret_m);

	// initialize value and choices for mover
	Vmov=-1e25;
	for (j=0; j<3; j++) {
		pmov[j]=-1;
	}

	Stmp[0]=W;
	Stmp[1]=Y;

	// solve mover problem
	// loop over housing choice grid
	for (hi=hi_start; hi<NCH; hi++) {
		cnobor= W - (1+psi)*Cpvals[hi];
		cmax= cnobor + (1-Cdeltavals[hi])*Cpvals[hi];
		if (cmax > 0) { // feasible ?
			if (search_mode == SEARCH_MODE_BISECT) {
				tmp_V= bisect(1, cmax, cnobor, hi, Stmp, tmp_choice);
			} else {
				tmp_V= gridsearch(1, 75, cmax, cnobor, hi, Stmp, tmp_choice);				
			}
			if (tmp_V>=Vmov) {
				hi_mov=hi;
				Vmov=tmp_V;
				memcpy(pmov,tmp_choice,3*sizeof(double));
			} else {
				// must be monotonic
				break;
			}
		}
	}
	// record result
	*(vmret)=Vmov;
	*(indexret)=1.00*hi_mov;
	memcpy(pmret,pmov,3*sizeof(double));

	
	// solve stayer problem
	// this assumes that state and choice grid are the same
	// first initialize all stayer values/policies to mover solution
	for (hi=0; hi<NSH; hi++) {
		memcpy(psret+hi*3,pmov,3*sizeof(double));
		vsret[hi]=Vmov;		
	}

	// now loop over housing state grid starting at mover solution
	// first upwards
	for (hi=hi_mov; hi<NSH; hi++) {
        // transform cash state variable;
		// stayer "gets back" transaction cost	
		WT = W + tc*Spvals[hi];
		// consumption is constrained by actual cash
		cnobor = WT - (1+psi)*Spvals[hi];
		cmax = cnobor + (1-Sdeltavals[hi])*Spvals[hi];
		Stmp[0]=WT;
		Vstay=-1e25;
		if (cmax>0) {
		// if feasible determine optimal consumption
			if (search_mode == SEARCH_MODE_BISECT) {
				Vstay= bisect(1, cmax, cnobor, hi, Stmp, tmp_choice);
			} else {
				Vstay= gridsearch(1, 50, cmax, cnobor, hi, Stmp, tmp_choice);				
			}
		}
		if (Vstay>Vmov) { 
			// if staying is better
			memcpy(psret+hi*3,tmp_choice,3*sizeof(double));
			vsret[hi]=Vstay;
		} else {
			// otherwise stop
			break;
		}
	}	

	// then downwards
	for (hi=hi_mov; hi>=0; hi--) {
        // transform cash state variable;
		// stayer "gets back" transaction cost	
		WT = W + tc*Spvals[hi];
		// consumption is constrained by actual cash
		cnobor = WT - (1+psi)*Spvals[hi];
		cmax = cnobor + (1-Sdeltavals[hi])*Spvals[hi];
		Stmp[0]=WT;
		Vstay=-1e25;
		if (cmax>0) {
		// if feasible determine optimal consumption
			if (search_mode == SEARCH_MODE_BISECT) {
				Vstay= bisect(1, cmax, cnobor, hi, Stmp, tmp_choice);
			} else {
				Vstay= gridsearch(1, 50, cmax, cnobor, hi, Stmp, tmp_choice);				
			}
		}
		if (Vstay>Vmov) { 
			// if staying is better
			memcpy(psret+hi*3,tmp_choice,3*sizeof(double));
			*(vsret+hi)=Vstay;
		} else {
			// otherwise stop
			break;
		}
	}	

}


double bisect(int mv, double cmax, double cmrest, int hi, double *S, double *x) {
	
	double xlow[3], xhigh[3], diff, vlow, vhigh, clower, cupper;
	int counter;

	counter=0;
	cupper=cmax;
	clower=0;
	if (mv) {
		xlow[0]=CgridH[hi]; 
		xhigh[0]=xlow[0];
	} else {
		xlow[0]=SgridH[hi]; 
		xhigh[0]=xlow[0];		
	}
	while (1) {
		// bisection low
		xlow[1]=clower + (cupper-clower)/4; // consumption
		xlow[2]=cmrest-xlow[1]; // bond
		// bisection high
		xhigh[1]=clower + (cupper-clower)*3/4; // consumption
		xhigh[2]=cmrest-xhigh[1]; // bond
		vlow=computeValue(mv,hi,S,xlow);
		vhigh=computeValue(mv,hi,S,xhigh);
		diff = vhigh-vlow;
		
		counter++;
		if (fabs(diff)<TOL) {
			// converged
			break;
		} else if (counter>MAXBISECT) {
			// failure
			mexPrintf("\nBisection failed at point %d: %f, %f, %f.",mv,S[0],S[1],xlow[0]); 
			break;
		} else if (diff>0) {
			clower = (cupper+clower)/2;
			// and chigh=chigh;
		} else {
			// diff < 0
			cupper = (cupper+clower)/2;
			// and clow=clow;
		}
	}

	memcpy(x,xlow,3*sizeof(double));
	return vlow;
}


double gridsearch(int mv, int NPS, double cmax, double cmrest, int hi, double *S, double *x) {
	
	double xt[3],vt,vresult;
	int i;

	xt[0]=CgridH[hi];
	vresult=-1e15;
	for (i=0; i<NPS; i++) {
		vt=-1e15;
		xt[1]=0.01+i*(cmax-0.01)/(NPS-1);
		xt[2]=cmrest-xt[1];
		vt=computeValue(mv,hi,S,xt);
		if (vt>vresult) {
			vresult=vt;
			memcpy(x,xt,3*sizeof(double));
		}
	}

	return vresult;
}


double computeValue (int mv, int hi, double *S, double *x) {

	double *pv, *sv, *dv;
	double Cash, Inc, hnext, c, b;
	double R_eff, prob, Ynext_perm, Ynext, price_next_stay, price_next_mov;
	double Wnext_stay, Wnext_mov, Snext[3], CV, CVmov, CVstay, expec;
	double val;
	int s;

	if (mv) {
		pv=CEpvals;
		sv=Csvals;
		dv=Cdeltavals;
	} else {
		pv=SEpvals;
		sv=Ssvals;
		dv=Sdeltavals;
	}

	// states
	Cash=S[0];
	Inc=S[1];

	// copy choices
	hnext=x[0];
	c=x[1];
	b=x[2];
	R_eff=Rf;
	if (b<0) {
		// if mortgage, add spread
		R_eff+=xi;
	}

	expec=0;
	for (s=0; s<NS; s++) {
		// get parameters for this state
		prob=process[s*RV];
        // permanent and temp component of income
		Ynext_perm=Inc*exp(g_age+process[s*RV+1]);
		Ynext=Ynext_perm*exp(process[s*RV+2]);
        // price growth and shock
        price_next_stay=(1-tc)*pv[hi];
        price_next_mov=price_next_stay*exp(process[s*RV+4]);
		// cash next period
        Wnext_stay=b*R_eff + price_next_stay + Ynext;
        Wnext_mov=b*R_eff + price_next_mov + Ynext;

		// mover continuation
		Snext[0]=Wnext_mov;
		Snext[1]=Ynext_perm;
		CVmov=evalV1(1,Snext);
		// stayer continuation
		Snext[0]=Wnext_stay;
		Snext[2]=hnext;
		CVstay=evalV1(0,Snext);
		
		// continuation value takes into account prob of forced move
		CV=(1-prm)*CVstay+prm*CVmov;

		expec += prob * pow(CV,1-hd_gamma);
	}

	val= pow( pow(c,1-rho) * pow(sv[hi],rho), 1-hd_gamma) + beta * expec;
    // normalize and probability of death
	val= (1-dpr)*pow(val, 1/(1-hd_gamma)) +  dpr*lastPeriodVal;

    return  val;
}


double evalV1(int mv, double *S) {
	
	double v;
	double *bndsi, *nptsi, bounds_eff[3][2];
	int dim, i, test,  npts_eff[3], npts_offset[3];

	if (mv) {
		dim=2;
	} else {
		dim=3;
	}

	// linear interpolation on two segments
	// determine segment and build effective bounds matrix
	for (i=0; i<dim; i++) {
		bndsi=stateBounds+i*3;  // 3 x DIM matrix of bounds
		nptsi=numberGridPoints+i*2; // 2 x DIM matrix of points in each segment
		// value greater than middle point?
		test=(S[i]>bndsi[1]);
		bounds_eff[i][0]=bndsi[0+test];
		bounds_eff[i][1]=bndsi[1+test];
		npts_eff[i]=(int)nptsi[test];
		npts_offset[i]=(int)(test*(nptsi[0]-1));		
	}
	v=evalV1_interp(mv,S,bounds_eff,npts_eff,npts_offset);

	return v;
}



double evalV1_interp(int mv, double *S, double *bounds, int *npts, int *npts_offset) {
	// linear interpolation over fine grid
	int simpind[2][3],indx[3],coord[3],i,dim;
	double sc[3],valw[2],valy[2],valh[2], result;
	int wi,yi,hi;
	double *bndsi;
    
	// init
	result=0;

    // starting sequence of indices
	for (i=0; i<3; i++) {
        indx[i]=i;
    }

	if (mv) {
		dim=2;
	} else {
		dim=3;
	}

	// determine simplex indices
	for (i=0; i<dim; i++) {
		bndsi=bounds+i*2;
		if (S[i] <= bndsi[0]) {
			// below lower bound
			simpind[0][i]=0;
			simpind[1][i]=0;	
			sc[i]=0;
		} else if (S[i] >= bndsi[1]) {
			// above upper bounds
			simpind[0][i]=npts[i]-1;
			simpind[1][i]=npts[i]-1;	
			sc[i]=1;
		} else {
			// in between: equally spaced points
			sc[i] = (S[i]-bndsi[0])/(bndsi[1]-bndsi[0])*(npts[i]-1);
			simpind[0][i] = (int)floor(sc[i]);
			simpind[1][i] = simpind[0][i]+1;
			sc[i] = sc[i]-simpind[0][i];
		}
		simpind[0][i] += npts_offset[i];
		simpind[1][i] += npts_offset[i];

	}


	if (dim==2) {
		// 2 dimensions
		for (yi=0; yi<2; yi++) {
			coord[1]=simpind[yi][1];
			for (wi=0; wi<2; wi++) {
				coord[0]=simpind[wi][0];
				valw[wi]=lookupValue(1,coord);
			}
			valy[yi]=(1-sc[0])*valw[0]+sc[0]*valw[1];
		}

		result=(1-sc[1])*valy[0]+sc[1]*valy[1];

	} else {
		// 3 dimensions
		for (hi=0; hi<2; hi++) {
			coord[2]=simpind[hi][2];
			for (yi=0; yi<2; yi++) {
				coord[1]=simpind[yi][1];
				for (wi=0; wi<2; wi++) {
					coord[0]=simpind[wi][0];
					valw[wi]=lookupValue(1,coord);
				}
				valy[yi]=(1-sc[0])*valw[0]+sc[0]*valw[1];
			}
			valh[hi]=(1-sc[1])*valy[0]+sc[1]*valy[1];
		}

		result=(1-sc[2])*valh[0]+sc[2]*valh[1];
	}

	return result;
}


double lookupValue(int mv, int *coord) {
	// lookup value functions based on grid.TensorGrid
    double val;
	int index;
    
    if (mv==1) {
		index=coord[1]*NGPtotal[0] + coord[0];
		if (index>NGPtotal[1]*NGPtotal[0]) {
			mexPrintf("Index out of bounds for mover VF, coord: %d, %d.\n",coord[0], coord[1]);
		}
        val=moverVF[index];
    } else {
		index=coord[2]*NGPtotal[1]*NGPtotal[0] + coord[1]*NGPtotal[0] + coord[0];
		if (index>NGPtotal[2]*NGPtotal[1]*NGPtotal[0]) {
			mexPrintf("Index %d out of bounds for stayer VF, coord: %d, %d, %d.\n",index, coord[0], coord[1], coord[2]);
		}
        val=stayerVF[index];
    }
    return val;
}


void processArgs(const mxArray *prhs[]) {

// arguments
// 1: cons search mode flag
// 2: 1 x 2 vector containing state pair [W,Y]
// 3: NCH x 5 vector with grid of feasible choices for H (for movers)
//    and associated values for prices, service flow, and delta;
//    first row: choice points
//    second: prices
//    third: expected prices
//    four: service flow
//    five: delta      
// 4: MinIndex: lowest index in choice grid at which to start searching
// 5: NSH x 5 vector with grid of state points for H (for stayers)
//    and associated values for prices, exp. prices, service flow, and delta;
//    row order same as above
// 6: 1 x NPARAM vector with scalar parameters to be passed in order
// 7: matrix with stochastic process for innovations to income and housing, RV x NS
//    first row: probabilities
//    second row: innovation to permanent component
//    third: temporary innovation
// 8: matrix with bounds of state variable grids 3 x 3
// 9: 1 x 2 cell array with value functions 
//    first element: mover function, NPmov X 2
//    second element: stayer function, NPstay x 3
// 10: matrix with number of points for each equally-spaced segment, 2 x 3

	mwSize *ntmp;
	mxArray *tmp_m;
	double *tmp_ptr, *params;
	int i;

	//mexPrintf("\nReading inputs...");
	// read arguments into global vars
	// search mode flag
	search_mode=mxGetScalar(prhs[0]);
	// vector with [W, Y]
	tmp_ptr = mxGetPr(prhs[1]); 
	W = tmp_ptr[0];
	Y = tmp_ptr[1];
	// H choice grid and associated values
	tmp_m=prhs[2];
	ntmp=mxGetDimensions(tmp_m);
	NCH=ntmp[0];
	tmp_ptr=mxGetPr(tmp_m);
	CgridH=tmp_ptr; // first row: choice grid
	Cpvals=tmp_ptr+NCH; // second row: price values
	CEpvals=Cpvals+NCH; // third row: expected price values next period
	Csvals=CEpvals+NCH; // fourth row: service flows
	Cdeltavals=Csvals+NCH; // fifth row: deltas
	// min index
	hi_start=(int)mxGetScalar(prhs[3]);
	// H state grid and associated values
	tmp_m=prhs[4];
	ntmp=mxGetDimensions(tmp_m);
	NSH=ntmp[0];
	tmp_ptr=mxGetPr(tmp_m);
	SgridH=tmp_ptr; // first row: choice grid
	Spvals=tmp_ptr+NSH; // second row: price values
	SEpvals=Spvals+NSH; // third row: expected price values next period
	Ssvals=SEpvals+NSH; // fourth row: service flows
	Sdeltavals=Ssvals+NSH; // fifth row: deltas
	// parameters
	params=mxGetPr(prhs[5]);
	hd_gamma = params[0];
	rho =params[1];
	beta = params[2];
	tc = params[3];
    psi = params[4];
	xi = params[5];
	Rf = params[6];
	prm = params[7];
	dpr = params[8];
	g_age = params[9];
	lastPeriodVal = params[10];
	// income process matrix
	tmp_m=prhs[6];
	ntmp=mxGetDimensions(tmp_m);
	RV = ntmp[0];
	NS = ntmp[1];
	process=mxGetPr(tmp_m);
	// state bounds matrix, 3 x 3 
	stateBounds=mxGetPr(prhs[7]);
	// value matrices
	moverVF=mxGetPr(mxGetCell(prhs[8],0));
	stayerVF=mxGetPr(mxGetCell(prhs[8],1));
	// matrix with number of points for each equally-spaced segment, 2 x 3
	numberGridPoints=mxGetPr(prhs[9]);
	// total number of points for each dimension
	for (i=0; i<3; i++) {
		tmp_ptr=numberGridPoints+i*2;
		NGPtotal[i]=(int)(tmp_ptr[0]+tmp_ptr[1]-1);
	}

}




