function [label, score] = classification(net, img_dir, classNames)

if length(classNames) > 50 
    input_size = [64,64,1];
else
    input_size = [28,28,1];
end

file_name = dir(fullfile(img_dir, ['*.mat']));
sum_score = zeros(1,length(classNames));
for i = 1:length(file_name)
    load(fullfile(file_name(i).folder, file_name(i).name));
    
    %save as png figure
%     if i == 7
%         f = figure('visible','off');
%         imshow(img_final);
%         saveas(f, [img_dir, '/', num2str(i),'.png']);
%     end
%     waitforbuttonpress
    img_final = reshape(img_final, input_size);
    [lb, score(i,:)] = classify(net, img_final);
    
    sum_score = sum_score + score(i,:);
end

[max_v, lb_idx] = max(sum_score);
label = string(classNames{lb_idx});

end

