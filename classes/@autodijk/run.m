function C = run(C, varargin)
%
% NAME
%
%  function C = run(C)
%
% ARGUMENTS
% INPUT
%	C		class		curvature_analyze  class
%
% OPTIONAL
%
% OUTPUT
%	C		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%	This method is the main entry point to "running" a curvature_analyze
%	class instance. It controls the main processing loop, viz. 
%
%               - populating internal subject info cell array
%               - creating the main data map that holds curvatures and processed
%                 information
%
% PRECONDITIONS
%
%	o the autodijk class instance must be fully instantiated.
%
% POSTCONDITIONS
%
%
% NOTE:
%
% HISTORY
% 02 November 2009
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'run');

csys_printf(C, 'Preprocessing subject...\n');
C               = subject_preprocess(C);
csys_printf(C, 'Constructing internals...\n');
C               = internals_build(C);
csys_printf(C, 'Performing dijkstra analysis...\n');
C               = autodijk_process(C);
csys_printf(C, 'Saving cost overlay...\n');
C               = cost_save(C);

keyboard;

[C.mstack_proc, element] = pop(C.mstack_proc);

