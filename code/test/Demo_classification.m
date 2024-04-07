function [label, score] = Demo_classification(net, img_dir, classNames)

if length(classNames) > 50 
    input_size = [64,64,1];
else
    input_size = [28,28,1];
end

file_name = dir(fullfile(img_dir, ['*.mat']));
sum_score = zeros(1,length(classNames));
idx = 0;
for i = 1:length(file_name)
    load(fullfile(file_name(i).folder, file_name(i).name));
    
%     %save as png figure
%     if i == 7
%         f = figure('visible','on');
%         imshow(img_show_f);
%         saveas(f, [img_dir, '/', num2str(i),'.png']);
%     end
%     waitforbuttonpress
    [x,y] = size(img_final);
    if x~= 28
        disp('test:')
        disp(i)
        disp(x)
    end

    if length(classNames) <= 50 
        if x == 28
            idx = idx + 1;
            img_final = reshape(img_final, input_size);
    %         [lb, score(i,:)] = classify(net, img_final);
            [lb, score(idx,:)] = classify(net, img_final);
        end
    else
        if x == 64
           idx = idx + 1;
            img_final = reshape(img_final, input_size);
    %         [lb, score(i,:)] = classify(net, img_final);
            [lb, score(idx,:)] = classify(net, img_final);
        end
    end
    
%     sum_score = sum_score + score(i,:);
    sum_score = sum_score + score(idx,:);
end

[max_v, lb_idx] = max(sum_score);
label = string(classNames{lb_idx});

end

