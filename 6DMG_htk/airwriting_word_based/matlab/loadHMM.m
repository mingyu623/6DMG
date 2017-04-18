% parse and plot the hmm model from HTK
function [meanMtx varMtx] = loadHMM(hmmName)
numStates = 0;
vecSize   = 0;
meanFlag = 0;
varFlag  = 0;
meanMtx = zeros(numStates, vecSize);
varMtx  = meanMtx;
state = 0;

fid = fopen(hmmName, 'r');
tline = fgetl(fid);
while ischar(tline)
    m = regexp(tline, '^<([A-Z]+)>', 'tokens');
    if size(m,1)>0
        switch char(m{:})
            case 'VECSIZE'
                cell = regexp(tline, '^<VECSIZE> (\d+)', 'tokens');
                str  = char(cell{:});
                vecSize = str2num(str);
            case 'NUMSTATES'
                cell = regexp(tline, '^<NUMSTATES> (\d+)', 'tokens');
                str  = char(cell{:});
                numStates = str2num(str) - 2;
                meanMtx = zeros(numStates, vecSize);
                varMtx  = zeros(numStates, vecSize);
            case 'STATE'
                cell = regexp(tline, '^<STATE> (\d+)', 'tokens');
                str = char(cell{:});
                state = str2num(str)-1;
            case 'MEAN'
                meanFlag = 1;
            case 'VARIANCE'
                varFlag = 1;                
        end    
    else
        if (meanFlag)
            res = sscanf(tline, '%f %f %f');
            meanMtx(state,:) = res';
            meanFlag = 0;
        elseif (varFlag)
            res = sscanf(tline, '%f %f %f');
            varMtx(state,:) = res';            
            varFlag = 0;            
        end
    end   
    
    %disp(tline)
    tline = fgetl(fid);
end

fclose(fid);