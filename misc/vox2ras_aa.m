function [M_R] = vox2ras_rsolve(Vc_C, inPlaneRotation, varargin)
%%
%% NAME
%%
%%     vox2ras_aa.m (vox2ras_a{uto}a{lign}) 
%%
%% AUTHOR
%%
%%	Rudolph Pienaar
%%
%% VERSION
%%
%% 	$Id:$
%%
%% SYNOPSIS
%%
%%     [M_R] = vox2ras_aa(Vc_C, inPlaneRotation, ch_orientation)
%%
%% ARGUMENTS
%%
%%      Vc_C		in      column vector defining a direction cosine for
%%					a volume
%%	inPlaneRotation	in	scalar float defining the in plane rotation as
%%					read from the data meas.asc file
%%	ch_orientation	in	optional character string definining the plane of
%%					the main slab orientation
%%	M_R		out	vox2ras rotational candidate
%%
%% DESCRIPTION
%%
%%	"vox2ras_aa" attempts to find a candidate vox2ras rotation matrix using
%%	techniques described in autoaligncorrect.cpp.
%%
%%	The optional character string, ch_orientation, defaults to 's' (sagittal)
%%	and defines the orientation of the main slab. This string is one of:
%%
%%		's'	sagittal
%%		'c'	coronal
%%		't'	transverse
%%
%% PRECONDITIONS
%%
%%	o The vector C is read from a Siemens meas.asc file such that
%%		ci	= sSliceArray.asSlice[0].sNormal.dSag
%%		cj	= sSliceArray.asSlice[0].sNormal.dCor
%%		ck	= sSliceArray.asSlice[0].sNormal.dTra
%%
%% POSTCONDITIONS
%%
%%	o All returned matrices are 4x4.
%%	o Only the rotations of the vox2ras matrix are determined by this function.
%%		The center of k-space is not determined.
%%
%% SEE ALSO
%%
%%	vox2ras_rsolve	- determine the rotational component of a vox2ras matrix
%%	vox2ras_ksolve	- determine the k-space col in RAS of a vox2ras matrix
%%	vox2ras_dfmeas	- main function: determines the vox2ras matrix from a
%%			  Siemens meas.asc file.
%% 
%% HISTORY
%%
%% 02 June 2004
%% o Initial design and coding.
%%

M_R		= zeros(4, 4);
Vc_Cn		= Vc_C./(norm(Vc_C));
%Vc_Cn		= Vc_C;
ch_orientation	= 's';
if length(varargin)
	ch_orientation	= varargin{1}(1);
end

%% phase reference vector
Vc_P	= zeros(3, 1);
switch ch_orientation
    case 't'
    	Vc_P(1)	= 0;
	Vc_P(2)	=  Vc_Cn(3)*sqrt(1/(Vc_Cn(2)*Vc_Cn(2)+Vc_Cn(3)*Vc_Cn(3)));
	Vc_P(3)	= -Vc_Cn(2)*sqrt(1/(Vc_Cn(2)*Vc_Cn(2)+Vc_Cn(3)*Vc_Cn(3)));
    case 'c'
	Vc_P(1)	=  Vc_Cn(2)*sqrt(1/(Vc_Cn(1)*Vc_Cn(1)+Vc_Cn(2)*Vc_Cn(2)));
	Vc_P(2)	= -Vc_Cn(1)*sqrt(1/(Vc_Cn(1)*Vc_Cn(1)+Vc_Cn(2)*Vc_Cn(2)));
    	Vc_P(3)	= 0;
    case 's'
	Vc_P(1)	= -Vc_Cn(2)*sqrt(1/(Vc_Cn(1)*Vc_Cn(1)+Vc_Cn(2)*Vc_Cn(2)));
	Vc_P(2)	=  Vc_Cn(1)*sqrt(1/(Vc_Cn(1)*Vc_Cn(1)+Vc_Cn(2)*Vc_Cn(2)));
    	Vc_P(3)	= 0;
    otherwise
        fprintf(1, 'Unknown orientation parameter passed. Returning with dummy M_R');
	return;
end

%% The readout reference vector is the cross product of Vc_Cn and Vc_P
Vc_R	= cross(Vc_Cn, Vc_P);

M_R(1:3, 1)	= Vc_P;
M_R(1:3, 2)	= Vc_R;
M_R(1:3, 3)	= Vc_C;

%% The above calculated rotation matrices define an (x,y) plane
%%	given by the first two column vectors. These reference
%%	vectors need to be rotated by inPlaneRotation to 
%%	reach the final rotational vox2ras.

theta_f		= inPlaneRotation;

M3_Mu	= [	 cos(theta_f)	 sin(theta_f)	0
		-sin(theta_f)	 cos(theta_f)	0
		 	0		0	1];
M3_R	= M_R(1:3,1:3)	* M3_Mu;
M_R(1:3,1:3)	= M3_R;

%% All done!
