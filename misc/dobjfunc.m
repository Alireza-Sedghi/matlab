function [f] = dobjfunc(X, str_labelFileName, varargin)
% NAME
%
%	function [f] = dobjfunc(X, str_labelFileName, varargin)
%
% ARGUMENTS
%
%	X			in (vector)	a vector of weights
%	str_labelFileName	in (string)	FreeSurfer label file 
%							describing refernce
%							(optimal) trajectory
%	verbosity		in (integer)	an optional verbosity
%							setting. If 0,
%							no output is echoed,
%							if 1, only final value
%							if >1, everything.
%
%	f			out (scalar)	the resultant from the 
%							input X
%
% DESCRIPTION
%
%	'dobjfunc' is a high level interface between a cost weight, X,
%	and a correlation (or fitness) scalar, f. It is used in 
%	the 'dijkstra_p1' processing system.
%
%	Essentially, this function sets the weight values for a path
%	search, calls an external 'dijkstra_p1' process with these
%	path values, and then again calls on the 'dijkstra_p1' to
%	determine a correlation between a found path and the reference
%	path, specified in <str_labelFileName>.
%%
% PRECONDITIONS
%	
% 	o <str_labelFileName> must contain a valid FreeSurfer label format
%	  file.
%
% POSTCONDITIONS
%
%	o the objective value 'f'.
%
% HISTORY
% 22 March 2005
% o Initial conceptualisation.
%
% 01 April 2005
% o Adpated to stand-alone.
%
% 13 April 2005
% o Shifted interface from 'dijk_dscipt.py' to 'dsh'
% o New back-end engine can compute correlation internally.
%
% 25 April 2005
% o Updated the dsh script to reflect that the new index of
%   the auxillary surface is 2.
%
% 08 August 2005
% o Added minor extensions to dsh generation to allow for
%   batch processing
%

	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function vprintf(level, str_msg)
	    if verbosity > level
		fprintf(1, str_msg);
	    end
	end

	function [dstr]	= WGHT_set(str_weight, f_val)
	    dstr = sprintf('WGHT %s set %f', str_weight, f_val);
	end


    verbosity    	= 0;

    if length(varargin)
	verbosity	= varargin{1};
    end

    str_dshFileName	= '/tmp/dobjfunc.dsh';
    fid_dsh		= fopen(str_dshFileName, 'w');

    f = 0.0;

    wghtCell	= {['wd'] ['wc'] ['wh'] ['wdc'] ['wdh'] ['wch'] ...
			['wdch'] ['wdir']};

    str_X 	= num2str(X);
    str_msgX	= sprintf('For weight vector = %s\n', str_X);
    vprintf(2, str_msgX);
    vprintf(2, 'Creating dsh script...')

    for w = 1:length(wghtCell) 
        dstr = WGHT_set(wghtCell{w}, X(w));
	fprintf(fid_dsh, '%s\n', dstr);
    end
    fprintf(fid_dsh, 'SURFACE active set 2\n');
    fprintf(fid_dsh, 'SURFACE active ripClear\n');
    fprintf(fid_dsh, 'SURFACE active set 0\n');
    fprintf(fid_dsh, 'SURFACE active ripClear\n');
    fprintf(fid_dsh, 'ENV surfacesClearFlag set 0\n');
    fprintf(fid_dsh, 'ENV surfacesSync set 0\n');
    fprintf(fid_dsh, 'RUN\n');
    fprintf(fid_dsh, 'LABEL auxSurface loadFrom %s\n', str_labelFileName);
    fprintf(fid_dsh, 'SURFACE correlationFunction do\n');
    fprintf(fid_dsh, 'ENV surfacesClearFlag set 1\n');
    fprintf(fid_dsh, 'ENV surfacesSync set 1\n');

    vprintf(2, '\t\t\t[ ok ]\n');

    vprintf(2, 'Determining path and correlation...');
    str_dsh = sprintf('dsh -s %s 2>/dev/null', ...
			 str_dshFileName);
    [ret str_console] = unix(str_dsh);
    vprintf(2, '\t\t\t[ ok ]\n');

    f = str2num(str_console);
    f = 1 - f;
    str_f = sprintf('\t\t\t[ %f ]\n', f');
    vprintf(2, str_f); 

    fclose(fid_dsh);

end % dobjfunc
