function [im_ch1, im_ch2, im_ch3] = nd2read(filename, varargin)
tic
finfo = nd2finfo(filename);
disp(['analyzing file structure used ', sprintf('%0.2f', toc), ' seconds'])

if any(strcmpi(varargin, 'StartFrame')), start_frame = varargin{find(strcmpi(varargin, 'StartFrame'))+1};
else, start_frame = 1;
end

if any(strcmpi(varargin, 'NumFrames'))
    n_frames = varargin{find(strcmpi(varargin, 'NumFrames'))+1};
    if isempty(n_frames), n_frames = finfo.img_seq_count; end
else, n_frames = finfo.img_seq_count;
end
    
im_ch1 = zeros(finfo.img_width, finfo.img_height, n_frames, 'uint16');
im_ch2 = zeros(finfo.img_width, finfo.img_height, n_frames, 'uint16');
if finfo.ch_count == 3
    im_ch3 = zeros(finfo.img_width, finfo.img_height, n_frames, 'uint16');
elseif finfo.ch_count == 4
  im_ch4 = zeros(finfo.img_width, finfo.img_height, n_frames, 'uint16');
else
    im_ch3 = [];
end

fid = fopen(filename, 'r');
filepos = find(strncmp('ImageDataSeq|0!',{finfo.file_structure(:).nameAttribute}, 14),1);
filepos = filepos + start_frame - 1;
fseek(fid,finfo.file_structure(filepos).dataStartPos, 'bof');

% fseek(fid, finfo.file_structure(strncmp('ImageDataSeq', ...
%   {finfo.file_structure(:).nameAttribute}, 12)).dataStartPos, 'bof');

tic
% Image extracted from ND2 has image width defined by its first dimension.
if finfo.padding_style == 1
  if finfo.ch_count == 4
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch3(:, ii) = temp(1, :);
        im_ch1(:, ii) = temp(2, :);
        im_ch2(:, ii) = temp(3, :);
        im_ch4(:, ii) = temp(4, :);
        fseek(fid, 2, 'cof');
    end
  elseif finfo.ch_count == 3
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch3(:, ii) = temp(1, :);
        im_ch1(:, ii) = temp(2, :);
        im_ch2(:, ii) = temp(3, :);
        fseek(fid, 2, 'cof');
    end
  else
     for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch1(:, ii) = temp(2, :);
        im_ch2(:, ii) = temp(3, :);
        fseek(fid, 2, 'cof');
    end 
  end
else
  if finfo.ch_count == 4
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch1(:, ii) = temp(1, :);
        im_ch2(:, ii) = temp(2, :);
        im_ch3(:, ii) = temp(3, :);
        im_ch4(:, ii) = temp(4, :);
    end
  elseif finfo.ch_count == 3
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch1(:, ii) = temp(1, :);
        im_ch2(:, ii) = temp(2, :);
        im_ch3(:, ii) = temp(3, :);
    end 
  else
      for f = 1:n_frames
          fseek(fid, finfo.file_structure(filepos).dataStartPos+8, 'bof');
          for ii = 1: finfo.img_height
              temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
              [finfo.ch_count finfo.img_width]);
              im_ch1(:, ii, f) = temp(1, :);
              if finfo.ch_count == 2, im_ch2(:, ii, f) = temp(2, :); end
          end
          filepos = filepos + 1;
      end 
  end
end

fclose(fid);

im_ch1 = permute(im_ch1, [2 1 3]);
im_ch2 = permute(im_ch2, [2 1 3]);

if finfo.ch_count == 3
    im_ch3 = permute(im_ch3, [2 1 3]);
elseif finfo.ch_count == 4
    im_ch4 = permute(im_ch4, [2 1 3]);
end
if any(strcmpi(varargin, 'use_ch4'))
  im_ch3 = im_ch4;
end
  

disp(['reading complete image data used ', sprintf('%0.2f', toc), ' seconds'])
end
