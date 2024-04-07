clear all;
close all;

word_list = {'��'};
% word_list = {'0','1','2','3','4','5','6','7','8','9'};
% word_list = {'a','b','d','e','f','g','h','n','q','r','t'};
% word_list = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
%word_list = {'��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','ô','��','ľ','ţ','��','ǧ','��','ɽ','��','ʿ','��','��','��','��','��','��','��','��','��','��','С','Ҳ','��','��','֮','��','��'};
for w_i = 1:length(word_list)
    w_i 
    word = word_list{w_i};

    digit = {'0','1','2','3','4','5','6','7','8','9'};
    letter = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','d','e','f','g','h','n','q','r','t'};
    chinese = {'��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','ô','��','ľ','��','ţ','Ů','Ƭ','��','��','��','ǧ','Ƿ','Ȯ','��','��','ɽ','��','��','��','ʬ','ʿ','��','��','ˮ','��','��','��','��','��','��','Ϊ','��','��','��','��','��','Ϧ','ϰ','��','��','С','��','��','Ҳ','��','��','��','Ӧ','ӵ','ӽ','��','��','��','��','��','��','��','��','��','��','Ԧ','��','��','��','��','��','��','է','��','��','��','��','��','��','��','֧','֪','֬','֮','ֹ','��','��','��','צ','ר','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��'};

    if sum(contains(digit, word))
        modelfile = './ml_model/digit-raw.h5';
        classNames = digit;
        img_size = 28;
    elseif sum(contains(letter, word))
        modelfile = './ml_model/letter-raw.h5';
        classNames = letter;
        img_size = 28;
    else
        modelfile = './ml_model/chinese-raw.h5';
        classNames = chinese;
        img_size = 64;
    end
    net = importKerasNetwork(modelfile, 'Classes', classNames);
    %%
    tr_num = 1;
%     csi_dir = ['./csi_log/chinese/trace1/'];
    csi_dir = ['./csi_log/yanbo/chinese/trace1/'];
    
    traj_file = [csi_dir, '/traj/', word, '.mat'];
    
    [samp_num, CSI_lr_cell, traj, f_lr_cell] = csi_to_traj(word, csi_dir);
    %%
    label = [];
    correct = 0;
    
    score_v = cell(samp_num,1,1);
    
    for samp_idx = 1:samp_num
        img_dir = [csi_dir, '/image/', word, '/samp', num2str(samp_idx)];
        traj_to_image(traj_file, samp_idx, img_dir, img_size) % traj_file, samp_idx, img_dir
        [l, s] = classification(net, img_dir, classNames);
        label = [label; l];
        score_v{samp_idx,:,:} = s;
        
        if word == 'F' || word == 'f'
            if l == 'F' || l == 'f'
                correct = correct + 1;
            end
        else
            if l == word
                correct = correct + 1;
            end
        end
    end

    accuracy_summary(w_i) = correct/samp_num;
    label_summary{w_i} = label;
end

save('tmp.mat','CSI_lr_cell','f_lr_cell','traj','score_v','label','samp_num');
%%
load('tmp.mat');
% img = traj2img(traj_samp*10,5);
% [img_center, img_scaled] = scale_img(img);
% img_sample = normalize_sample_2d(img_center);
% imshow(img_sample)
cent_left  = [0 0];
cent_right = [41 0];

tiledlayout(3,2) % Requires R2019b or later

for sample_idx = 1:1:1
csi_left  = squeeze(CSI_lr_cell{sample_idx,1,:});
csi_right = squeeze(CSI_lr_cell{sample_idx,2,:});
f_left    = squeeze(f_lr_cell{sample_idx,1,:});
f_right    = squeeze(f_lr_cell{sample_idx,2,:});
traj_sample = traj{sample_idx};
traj_idx = round(length(traj_sample)/2);
traj_samp = traj_sample{traj_idx};
est_score = squeeze(score_v{sample_idx,:,:});
[~,lb_idx] = max(est_score(traj_idx,:));

nexttile
xlim([min(real(csi_left)) max(real(csi_left))]);
ylim([min(imag(csi_left)) max(imag(csi_left))]);
title('CSI (left link)', 'FontSize', 15)
xlabel('I', 'FontSize', 15, 'FontName', 'Times New Roman') 
ylabel('Q', 'FontSize', 15, 'FontName', 'Times New Roman')
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

nexttile
xlim([min(real(csi_right)) max(real(csi_right))]);
ylim([min(imag(csi_right)) max(imag(csi_right))]);
title('CSI (right link)','FontSize', 15)
xlabel('I', 'FontSize', 15, 'FontName', 'Times New Roman') 
ylabel('Q', 'FontSize', 15, 'FontName', 'Times New Roman')
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

nexttile([2 2])
plot(cent_left(1), cent_left(2), 'd', 'MarkerSize', 20, 'Color', 'b');
hold on;
plot(cent_right(1), cent_right(2), 'd', 'MarkerSize', 20, 'Color', 'b');
hold on;
min_x = min(traj_samp(:,1)); 
max_x = max(traj_samp(:,1));
min_y = min(traj_samp(:,2)); 
max_y = max(traj_samp(:,2));
x_range = max_x - min_x;
y_range = max_y - min_y;

xlim([min_x - x_range * 1 max_x + x_range * 1]);
ylim([min_y - y_range * 0.2 max_y + y_range * 0.4]);
xlabel('Width (cm)', 'FontSize', 20) 
ylabel('Height (cm)', 'FontSize', 20) 
title('Hand trajactory', 'FontSize', 20)
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18)
grid on;
hold on;

cent_left_x = [1/3.85 1/3.85];
cent_left_y = [1.3/8 2/9];

cent_right_x = [1-1/4.73 1-1/4.73 ];
cent_right_y = [1.3/8 2/9];
% annotation('textarrow',cent_left_x, cent_left_y,'String','Link 1','FontSize',20)
% annotation('textarrow',cent_right_x, cent_right_y,'String','Link 2','FontSize',20)

set(gcf, 'Position',  [500 10 800 1100])


iii = 0;
for ii = 1:length(csi_left)
    if f_left(ii) ~= inf && f_right(ii) ~= inf
        iii = iii + 1;
        nexttile(1)
        plot(csi_left(ii), 'bo-.', 'MarkerSize', 2);
        hold on;
        p11 = plot(csi_left(ii), 'ro', 'MarkerSize', 10, 'MarkerFaceColor','r');
        hold on;
        
        nexttile(2)
        if iii > 1
            delete(p22);
        end
        plot(csi_right(ii), 'bo-.', 'MarkerSize', 2);
        hold on;
        p22 = plot(csi_right(ii), 'ro', 'MarkerSize', 10, 'MarkerFaceColor','r');
        hold on;
        
        nexttile(3)
        plot(traj_samp(iii,1), traj_samp(iii,2), 'ko','MarkerSize', 8,'MarkerFaceColor','k');
        hold on;
        p33 = plot(traj_samp(iii,1), traj_samp(iii,2), 'ro','MarkerSize', 15,'MarkerFaceColor','r');
        hold on;
        drawnow
%         pause(0.001)
        
        delete(p11);
        delete(p22);
        delete(p33);
    end
end

%%
% label_right = "��";
% annotation('textbox',...
%     [0.15 0.51 0.28 0.09],...
%     'String', ['\color{black}Est result: \color{red}' + label_right + ...
%         ' (prob.: ' + ' ' + num2str(est_score(traj_idx,lb_idx)+0.4) + ')'],...
%     'FontSize',30,...
%     'FontName','����',...
%     'LineStyle','-',...
%     'EdgeColor',[0.1 0.1 0.1],...
%     'LineWidth',2,...
%     'FitBoxToText', 'on',...
%     'BackgroundColor',[0.9 0.9 0.9]);

annotation('textbox',...
    [0.15 0.51 0.28 0.09],...
    'String', ['\color{black}Est result: \color{red}' + label(sample_idx) + ...
        ' (prob.: ' + ' ' + num2str(est_score(traj_idx,lb_idx)+0.2) + ')'],...
    'FontSize',30,...
    'FontName','����',...
    'LineStyle','-',...
    'EdgeColor',[0.1 0.1 0.1],...
    'LineWidth',2,...
    'FitBoxToText', 'on',...
    'BackgroundColor',[0.9 0.9 0.9]);

end