function allcellids = findallcells(varargin)
%FINDALLCELLS   Find all clustered cells on the CellBase path.
%   IDS = FINDALLCELLS finds all clustered cells in the default cellbase
%   directory and subdirectories.
%
%   IDS = FINDALLCELLS(DR) returns cell IDs from DR.
%
%   See also FINDCELLPOS.

%   Edit log: AK  3/04; ZFM 7/05; BH 3/21/11, 4/23/13, TO 05/2018

% Get cellbase preferences
P = getcbpref();
cellbase_datapath = P.datapath;
cell_pattern = P.Spikes_cell_pattern;

% Input argument check
if nargin > 0
    ratdir = varargin{1};
    if ~exist(fullfile(cellbase_datapath,ratdir),'dir')
        disp('Directory doesn''t exist.')
        return
    end
else
    ratdir = listdir(cellbase_datapath);
end
if ischar(ratdir)
    ratdir = {ratdir};
end
if isempty(ratdir)
    disp('FINDALLCELLS: No cells found.');
    return
end

% Get cell IDs
k = 1;  % counter for cell IDs
allcellids = {};
for rdir = 1:length(ratdir)   % animal loop
    ratpath = fullfile(cellbase_datapath,char(ratdir(rdir)));
    sessiondir = [{''} listdir(char(ratpath))];
    for sdir = 1:length(sessiondir)   % session loop
        
        % Added options for specifying an cut directory below the session
        % directory
        if isfield(P,'group')
            % Deal with hierarchy of cut directories
            cut_dirs = P.group;
            if iscell(cut_dirs)
                % there is more than one cut directory specified,
                % return the first existing directory (ie cut directories are in order of
                % preference)
                for n = 1:length(cut_dirs)
                    cdir = fullfile(ratpath,char(sessiondir(sdir)),cut_dirs{n});
                    if exist(cdir,'file')
                        fullsessiondir = cdir;
                        break
                    end
                    % no cut directory found, use route
                    fullsessiondir = fullfile(ratpath,char(sessiondir(sdir)));
                end
            else
                % only one cut directory set
                fullsessiondir = fullfile(ratpath,char(sessiondir(sdir)),cut_dirs);
            end
            
            % Now check for cells
            cellfiles = listfiles(fullsessiondir,cell_pattern);
        else
            fullsessiondir = fullfile(ratpath,char(sessiondir(sdir)));
            cellfiles = listfiles(fullsessiondir,cell_pattern);
        end
        
        % Convert filenames to cell IDs
        for fnum = 1:length(cellfiles)   % filename loop
            fname = fullfile(fullsessiondir,char(cellfiles(fnum)));
            if k == 1 %set session separator as preference only once
                 [cellid, session_separator] = fname2cellid(fname,P);
                 if cellid~=0
                    setcbpref('session_separator',session_separator);
                 end
            else
                 cellid = fname2cellid(fname,P);
            end
            if cellid ~= 0
                allcellids{k} = cellid;
                k = k+1;
            end
        end   % end of filename loop
    end   % end of session loop
end   % end of animal loop