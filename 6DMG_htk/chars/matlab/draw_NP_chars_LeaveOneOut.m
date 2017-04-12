% Draw POS of all chars (from NP2DuvNV2D)
close all;

% hmmdef_comp = 'C:/Mingyu/6DMG_word_SNG1_multi_lig2/char_lig/NP2DuvNV2D/Extension/iso/hmm3/hmmdefs_iso';
% hmmdef_comp = 'C:/Mingyu/6DMG_word_letter_based/SNG1_lig_tree_leaveOneOut/NP2DuvNV2D/M1/tree0/trihmm5/hmmdefs';

hmmdef = '../LeaveOneOut/NP2DuvNV2D/M1/tree0/trihmm5/hmmdefs';

chars= ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J'...
        'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T'...
        'U' 'V' 'W' 'X' 'Y' 'Z'];
A_start_pt = zeros(26,2);
A_end_pt   = zeros(26,2);
B_start_pt = zeros(26,2);
B_end_pt   = zeros(26,2);

for i=1:26
    charName = chars(i);
    %A_mat = load(sprintf('C:/Mingyu/6DMG_mat/matR_char/upper_%s_M1_t01.mat',charName)); % raw data
    hmmName = sprintf('upp_%s',charName);
    [A_meanMtx A_varMtx] = loadHMM(sprintf('../iso_char/NP/M1/hmm2/%s',hmmName));
    %[A_meanMtx A_varMtx] = loadHMMdef(hmmdef_comp,hmmName);
    %[B_meanMtx B_varMtx] = loadHMMdef(hmmdef,hmmName);
        
    A_start_pt(i,:) = A_meanMtx(1,1:2);
    A_end_pt(i,:)   = A_meanMtx(end,1:2);
    %B_start_pt(i,:) = B_meanMtx(1,1:2);
    %B_end_pt(i,:)   = B_meanMtx(end,1:2);
    
    
    figIdx = ceil(i/5);
    subfigIdx = mod(i,5);
    if subfigIdx==0, subfigIdx=5; end
    figure(figIdx);
    subplot(2,5,subfigIdx); hold on;    
    plot(A_meanMtx(:,1),A_meanMtx(:,2),...
                 '--mo','LineWidth',1,...
                 'MarkerEdgeColor','k',...
                 'MarkerFaceColor','g',...
                 'MarkerSize',5);
    axis([-2 2 -2 2]);
    axis equal;
    
    
    for j = 1:size(A_meanMtx,1)
        ellipse(sqrt(A_varMtx(j,1)),sqrt(A_varMtx(j,2)),0,A_meanMtx(j,1),A_meanMtx(j,2));
    end
%     subplot(2,5,subfigIdx+5); hold on;
%     plot(B_meanMtx(:,1),B_meanMtx(:,2),...
%                 '--rs','LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor','r',...
%                 'MarkerSize',5);
%     axis([-2 2 -2 2]);
%     axis equal;
%     for j = 1:size(B_meanMtx,1)
%         ellipse(sqrt(B_varMtx(j,1)),sqrt(B_varMtx(j,2)),0,B_meanMtx(j,1),B_meanMtx(j,2),'r');
%     end    
end

% % Draw the filler HMM
% subplot(2,5,10);
% [B_meanMtx B_varMtx] = loadHMMdef(hmmdef,'fil');
% plot(B_meanMtx(1,1),B_meanMtx(1,2),...
%      '--rs','LineWidth',2,...
%      'MarkerEdgeColor','k',...
%      'MarkerFaceColor','r',...
%      'MarkerSize',5);
% ellipse(sqrt(B_varMtx(1,1)),sqrt(B_varMtx(1,2)),0,B_meanMtx(1,1),B_meanMtx(1,2),'r');
% axis([-2 2 -2 2]);
% axis equal;


%==============================================================
% % Draw the iso ligs from hmmdef_comp
% h7 = figure(7);
% for s=1:3
%     for e=1:7        
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));        
%         [B_meanMtx B_varMtx] = loadHMMdef(hmmdef_comp,ligName);
%         plot(B_meanMtx(:,1),B_meanMtx(:,2), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-2 2 -2 2]);        
%     end
% end
% mtit(h7, 'multi-lig (comp)');

%=============================================
% % Draw the HERest ligs with iso initial
% h8 = figure(8);
% for s=1:3
%     for e=1:7        
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));        
%         [B_meanMtx B_varMtx] = loadHMMdef(hmmdef,ligName);
%         plot(B_meanMtx(:,1),B_meanMtx(:,2), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-2 2 -2 2]);
%         for j = 1:size(B_meanMtx,1)
%             ellipse(sqrt(B_varMtx(j,1)),sqrt(B_varMtx(j,2)),0,B_meanMtx(j,1),B_meanMtx(j,2),'r');
%         end    
%     end
% end
% mtit(h8, 'multi-lig (embedded fil)');