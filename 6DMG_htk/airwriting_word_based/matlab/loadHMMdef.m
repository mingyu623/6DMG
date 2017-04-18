% Mingyu Chen @ Oct/5/2012
% parse HMM model from the HMMdef of HTK
function [meanMtx varMtx] = loadHMMdef(hmmDefFile, hmmName)
fid = fopen(hmmDefFile, 'r');
tline = fgetl(fid);
S_meanMtx = [];
S_varMtx  = [];
E_meanMtx = [];
E_varMtx  = [];
begin_HMM = 0;
while ischar(tline)
    if (begin_HMM==0) % fetch tie states first
        m = regexp(tline, '^~s "([E|S])(\d)"', 'tokens');
        if (size(m,1)>0) % find an tied state
            opt1 = char(m{:}{1});
            opt2 = str2num(char(m{:}{2}));
            [state_mean state_var] = loadOneState(fid);
            switch opt1
                case 'S'
                    S_meanMtx = [S_meanMtx; state_mean];
                    S_varMtx  = [S_varMtx;  state_var ];
                case 'E'
                    E_meanMtx = [E_meanMtx; state_mean];
                    E_varMtx  = [E_varMtx;  state_var ];
            end
        end
    end
    
    m = regexp(tline, '^~h "([\w]+)"', 'tokens');
    if (size(m,1)>0) % find an HMM
        begin_HMM=1;
        hmm = char(m{:});
        if (strcmpi(hmm, hmmName)) % find "hmmName"
            disp(['load ' hmm]);
            %=======================================================
            [meanMtx varMtx] = loadOneHmm(fid, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx);
            break;
            %=======================================================
        end        
    end    
    tline = fgetl(fid);
end
fclose(fid);

function [meanMtx varMtx] = loadOneHmm(fid, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx)
numStates = 0;
state     = 0;
meanMtx = [];
varMtx  = [];
tline = fgetl(fid);
while(ischar(tline))
    m = regexp(tline, '^<([A-Z]+)> (\d+)', 'tokens');
    if size(m,1)>0
        opt1 = char(m{:}{1});
        opt2 = str2num(char(m{:}{2}));
        switch opt1
            case 'VECSIZE'                
                vecSize = opt2;
            case 'NUMSTATES'
                numStates = opt2 - 2;               
            case 'STATE'               
                state = opt2-1;
                [state_mean state_var] = loadOneState(fid, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx);                            
                meanMtx = [meanMtx; state_mean];            
                varMtx  = [varMtx;  state_var ];
                if (state==numStates), break; end;
        end
    end
    tline = fgetl(fid);
end
%disp('loadOneHmm');

function [state_mean state_var] = loadOneState(fid, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx)
tline = fgetl(fid);
m = regexp(tline, '^~s "([E|S])(\d)"', 'tokens');
if (size(m,1)>0) % find an tied state
    opt1 = char(m{:}{1});
    opt2 = str2num(char(m{:}{2}));
    [state_mean state_var] = loadOneTieState(opt1, opt2, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx);
else % find a normal state
    while(ischar(tline))
        m = regexp(tline, '^<([A-Z]+)> (\d+)', 'tokens');
        if size(m,1)>0
            opt1 = char(m{:}{1});
            opt2 = str2num(char(m{:}{2}));
            switch opt1
                case 'MEAN'
                    state_mean = getNumsInRow(fid);
                case 'VARIANCE'
                    state_var  = getNumsInRow(fid);
                    break;
            end
        end
        tline = fgetl(fid);
    end
end

function [state_mean state_var] = loadOneTieState(opt1, opt2, S_meanMtx, S_varMtx, E_meanMtx, E_varMtx)
    switch opt1
        case 'S'
            state_mean = S_meanMtx(opt2,:);
            state_var  = S_varMtx (opt2,:);
        case 'E'
            state_mean = E_meanMtx(opt2,:);
            state_var  = E_varMtx (opt2,:);
    end

function row = getNumsInRow(fid)
tline = fgetl(fid);
res = sscanf(tline, '%f');
row = res';

