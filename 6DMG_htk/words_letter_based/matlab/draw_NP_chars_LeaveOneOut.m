% Draw POS of all chars (from NPNV)
close all;
hmmdef = 'C:\Mingyu\6DMG_word_detect\SNG1_lig_tree_leaveOneOut\NPNV\Z1\tree0\trihmm5\hmmdefs';
%hmmdef = 'C:\Mingyu\6DMG_word_detect\SNG1_lig_decision_tree\trihmm5\hmmdefs';
%hmmdef = 'C:\Mingyu\6DMG_word_SNG1_multi_lig2\char_lig_old_SN\NPNV\Extension\iso\hmm3\hmmdefs_iso';
chars= ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J'...
        'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T'...
        'U' 'V' 'W' 'X' 'Y' 'Z'];
A_start_pt = zeros(26,3);
A_end_pt   = zeros(26,3);
B_start_pt = zeros(26,3);
B_end_pt   = zeros(26,3);

for i=1:26
    charName = chars(i);
    A_mat = load(sprintf('C:/Mingyu/6DMG_mat/matR_char/upper_%s_M1_t01.mat',charName)); % raw data
    hmmName = sprintf('upp_%s',charName);
    [A_meanMtx A_varMtx] = loadHMM(sprintf('C:/Mingyu/6DMG_word_SNG1_multi_lig2/iso_char/NPNV/all/hmm2/%s',hmmName));
    [B_meanMtx B_varMtx] = loadHMMdef(hmmdef,hmmName);
    A_p = A_mat.gest(2:4,:);
    A_np = normalizePos(A_p);
    
    A_start_pt(i,:) = A_meanMtx(1,1:3);
    A_end_pt(i,:)   = A_meanMtx(end,1:3);
    B_start_pt(i,:) = B_meanMtx(1,1:3);
    B_end_pt(i,:)   = B_meanMtx(end,1:3);
    
    
    figIdx = ceil(i/10);
    subfigIdx = mod(i,10);
    if subfigIdx==0, subfigIdx=10; end
    figure(figIdx);
    subplot(2,5,subfigIdx); hold on;
    plot3(A_np(1,:),A_np(2,:),A_np(3,:));
%      plot3(A_meanMtx(:,1),A_meanMtx(:,2),A_meanMtx(:,3), ...
%                  '--mo','LineWidth',1,...
%                  'MarkerEdgeColor','k',...
%                  'MarkerFaceColor','g',...
%                  'MarkerSize',5);
    plot3(B_meanMtx(:,1),B_meanMtx(:,2),B_meanMtx(:,3), ...
                '--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r',...
                'MarkerSize',5);
    axis equal;
end


%==============================================================
% figure(5);
% subplot(2,2,1); hold on;
% title('Starting points (iso char NP all)')
% start_query = [-.5 0.8 0; 0 0.8 0; 0.5 0.8 0];
% % start_idx = knnsearch(start_query,start_pt);
% start_idx = kmeans(A_start_pt, 3, 'start', start_query);
% plot3(A_start_pt(start_idx==1,1),A_start_pt(start_idx==1,2),A_start_pt(start_idx==1,3), 'ro');
% plot3(A_start_pt(start_idx==2,1),A_start_pt(start_idx==2,2),A_start_pt(start_idx==2,3), 'go');
% plot3(A_start_pt(start_idx==3,1),A_start_pt(start_idx==3,2),A_start_pt(start_idx==3,3), 'bo');
% axis equal;
% axis([-1 1 -1 1 -.2 .2]);
% view(2); % set to X-Y view
% 
% subplot(2,2,2); hold on;
% title('Ending points (iso char NP all)');
% start_query = [-.5 -.8 0; 0 -.8 0; .5 -.8 0;...
%                -.5 0 0    ; .5 0 0; ...
%                0 .8 0; .5 .8 0];
% end_idx = kmeans(A_end_pt, 7, 'start', start_query);
% plot3(A_end_pt(end_idx==1,1),A_end_pt(end_idx==1,2),A_end_pt(end_idx==1,3), 'rx');
% plot3(A_end_pt(end_idx==2,1),A_end_pt(end_idx==2,2),A_end_pt(end_idx==2,3), 'gx');
% plot3(A_end_pt(end_idx==3,1),A_end_pt(end_idx==3,2),A_end_pt(end_idx==3,3), 'bx');
% plot3(A_end_pt(end_idx==4,1),A_end_pt(end_idx==4,2),A_end_pt(end_idx==4,3), 'ro');
% plot3(A_end_pt(end_idx==5,1),A_end_pt(end_idx==5,2),A_end_pt(end_idx==5,3), 'go');
% plot3(A_end_pt(end_idx==6,1),A_end_pt(end_idx==6,2),A_end_pt(end_idx==6,3), 'bo');
% plot3(A_end_pt(end_idx==7,1),A_end_pt(end_idx==7,2),A_end_pt(end_idx==7,3), 'r*');
% axis equal;
% axis([-1 1 -1 1 -.2 .2]);
% view(2); % set to X-Y view
% A_start_idx = start_idx;
% A_end_idx   = end_idx;
% 
% subplot(2,2,3); hold on;
% title('Starting points (char lig NP M1 3of4 run00)')
% start_query = [-.5 0.8 0; 0 0.8 0; 0.5 0.8 0];
% % start_idx = knnsearch(start_query,start_pt);
% start_idx = kmeans(B_start_pt, 3, 'start', start_query);
% plot3(B_start_pt(start_idx==1,1),B_start_pt(start_idx==1,2),B_start_pt(start_idx==1,3), 'ro');
% plot3(B_start_pt(start_idx==2,1),B_start_pt(start_idx==2,2),B_start_pt(start_idx==2,3), 'go');
% plot3(B_start_pt(start_idx==3,1),B_start_pt(start_idx==3,2),B_start_pt(start_idx==3,3), 'bo');
% axis equal;
% axis([-1 1 -1 1 -.2 .2]);
% view(2); % set to X-Y view
% 
% subplot(2,2,4); hold on;
% title('Ending points (char lig NP M1 3of4 run00)');
% start_query = [-.5 -.8 0; 0 -.8 0; .5 -.8 0;...
%                -.5 0 0    ; .5 0 0; ...
%                0 .8 0; .5 .8 0];
% end_idx = kmeans(B_end_pt, 7, 'start', start_query);
% plot3(B_end_pt(end_idx==1,1),B_end_pt(end_idx==1,2),B_end_pt(end_idx==1,3), 'rx');
% plot3(B_end_pt(end_idx==2,1),B_end_pt(end_idx==2,2),B_end_pt(end_idx==2,3), 'gx');
% plot3(B_end_pt(end_idx==3,1),B_end_pt(end_idx==3,2),B_end_pt(end_idx==3,3), 'bx');
% plot3(B_end_pt(end_idx==4,1),B_end_pt(end_idx==4,2),B_end_pt(end_idx==4,3), 'ro');
% plot3(B_end_pt(end_idx==5,1),B_end_pt(end_idx==5,2),B_end_pt(end_idx==5,3), 'go');
% plot3(B_end_pt(end_idx==6,1),B_end_pt(end_idx==6,2),B_end_pt(end_idx==6,3), 'bo');
% plot3(B_end_pt(end_idx==7,1),B_end_pt(end_idx==7,2),B_end_pt(end_idx==7,3), 'r*');
% axis equal;
% axis([-1 1 -1 1 -.2 .2]);
% view(2); % set to X-Y view
% B_start_idx = start_idx;
% B_end_idx   = end_idx;
% 
% % print the groups of start & end points
% for i=1:3
%     fprintf('S%d (A): %s\n', i, chars(A_start_idx==i));
%     fprintf('S%d (B): %s\n', i, chars(B_start_idx==i));
% end
% 
% for i=1:7
%     fprintf('E%d (A): %s\n', i, chars(A_end_idx==i));
%     fprintf('E%d (B): %s\n', i, chars(B_end_idx==i));
% end
% 
% %=============================================
% % Draw the iso ligs from M1's data
% h6 = figure(6);
% for s=1:3
%     for e=1:7
%         if ((s==3 && e>3) || (s==2 && e==6))
%             continue;
%         end
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));
%         hmmName = sprintf('iso_lig/NP/hmm2/%s',ligName);
%         [B_meanMtx B_varMtx] = loadHMM(hmmName);
%         plot3(B_meanMtx(:,1),B_meanMtx(:,2),B_meanMtx(:,3), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-1 1 -1 1 -.2 .2]);
%         view(2); % set to X-Y view
%     end
% end
% mtit(h6, 'iso ligs from M1 data');
% 
% %=============================================
% % Draw the HERest ligs with flat initial (HCompV)
% h7 = figure(7);
% for s=1:3
%     for e=1:7
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));
%         [B_meanMtx B_varMtx] = loadHMMdef(hmmdef_flat,ligName);
%         plot3(B_meanMtx(:,1),B_meanMtx(:,2),B_meanMtx(:,3), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-1 1 -1 1 -.2 .2]);
%         view(2); % set to X-Y view
%     end
% end
% mtit(h7, 'multi-lig (flat)');
% %=============================================
% % Draw the HERest ligs with tie initial
% h8 = figure(8);
% for s=1:3
%     for e=1:7
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));
%         [B_meanMtx B_varMtx] = loadHMMdef(hmmdef_tie,ligName);
%         plot3(B_meanMtx(:,1),B_meanMtx(:,2),B_meanMtx(:,3), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-1 1 -1 1 -.2 .2]);
%         view(2); % set to X-Y view
%     end
% end
% mtit(h8, 'multi-lig (tie)');
% %=============================================
% % Draw the HERest ligs with iso initial
% h9 = figure(9);
% for s=1:3
%     for e=1:7        
%         idx = (s-1)*7 + e;
%         ligName = sprintf('lig_E%dS%d',e,s);
%         subplot(3,7,idx); hold on;
%         title(sprintf('E%dS%d',e,s));        
%         [B_meanMtx B_varMtx] = loadHMMdef(hmmdef_iso,ligName);
%         plot3(B_meanMtx(:,1),B_meanMtx(:,2),B_meanMtx(:,3), ...
%                     '--rs','LineWidth',2,...
%                     'MarkerEdgeColor','k',...
%                     'MarkerFaceColor','r',...
%                     'MarkerSize',3);
%         axis equal;
%         axis([-1 1 -1 1 -.2 .2]);
%         view(2); % set to X-Y view
%     end
% end
% mtit(h9, 'multi-lig (iso)');