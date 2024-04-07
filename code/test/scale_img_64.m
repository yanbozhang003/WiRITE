function [scaled_img] = scale_img(img)
[r c] = size(img);
pad_img = padarray(img, [round((max(r,c)-r)/2) round((max(r,c)-c)/2)], 'both');
scaled_img = imresize(pad_img, [56 56]);
scaled_img = padarray(scaled_img, [4 4], 'both');


tot_mass = sum(scaled_img(:));
[ii,jj] = ndgrid(1:size(scaled_img,1),1:size(scaled_img,2));
cent_x = round(sum(ii(:).*double(scaled_img(:)))/tot_mass);
cent_y = round(sum(jj(:).*double(scaled_img(:)))/tot_mass);

shift_x = 32 - cent_x;
shift_y = 32 - cent_y;

shift_x = min(4, abs(shift_x)) * sign(shift_x);
shift_y = min(4, abs(shift_y)) * sign(shift_y);
    
scaled_centered_img = zeros(64,64);

for i = 5:60
    for j = 5:60
        scaled_centered_img(i + shift_x,j+shift_y) = scaled_img(i,j);
    end
end

end

