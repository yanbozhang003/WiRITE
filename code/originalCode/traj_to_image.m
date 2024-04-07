function traj_to_image(traj_file, samp_idx, img_dir, img_size)

if ~exist(img_dir, 'dir')
       mkdir(img_dir);
end

load(traj_file);

if img_size == 28
    mul = 20;
    thk = 5;
else
    mul = 100;
    thk = 3;
end

for i = 1:length(traj{samp_idx})
    img_raw = traj2img(traj{samp_idx}{i} * mul, thk);
    if img_size == 28
        img_ct = scale_img_28(img_raw);
    else
        img_ct = scale_img_64(img_raw);
    end
    img_ct = max(img_ct, 0);
    img_final = normalize_sample_2d(img_ct);
    
    img_file = [img_dir, '/', num2str(i)];
    save(img_file, 'img_final');
end

end

