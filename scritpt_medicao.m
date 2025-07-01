clc; clear; close all;

videoFile = 'pupil01.mp4';
outputVideoFile = strcat('video/_', strrep(videoFile,'.mp4','_circle.mp4'));
greyVidFile = strcat('video/_', strrep(videoFile,'.mp4','_grey.mp4'));
binVidFile = strcat('video/_', strrep(videoFile,'.mp4','_bin.mp4'));
cleanVidFile = strcat('video/_', strrep(videoFile,'.mp4','_clean.mp4'));
invVidFile = strcat('video/_', strrep(videoFile,'.mp4','_inv.mp4'));
bboxVidFile = strcat('video/_', strrep(videoFile,'.mp4','_bboxes.mp4'));

video = VideoReader(videoFile);
firstFrame = readFrame(video);

[center, ~, st_area] = find_pupil(firstFrame, false);


pupilArea = [video.NumFrames];
frameCount = 0;

video = VideoReader(videoFile); 

outputVideo = VideoWriter(outputVideoFile, 'MPEG-4');
outputVideo.FrameRate = video.FrameRate;
open(outputVideo);
greyVid = VideoWriter(greyVidFile, 'MPEG-4');
greyVid.FrameRate = video.FrameRate;
open(greyVid);
binVid = VideoWriter(binVidFile, 'MPEG-4');
binVid.FrameRate = video.FrameRate;
open(binVid);
cleanVid = VideoWriter(cleanVidFile, 'MPEG-4');
cleanVid.FrameRate = video.FrameRate;
open(cleanVid);
invVid = VideoWriter(invVidFile, 'MPEG-4');
invVid.FrameRate = video.FrameRate;
open(invVid);
bboxVid = VideoWriter(bboxVidFile, 'MPEG-4');
bboxVid.FrameRate = video.FrameRate;
open(bboxVid);

while hasFrame(video)
    frame = readFrame(video);
    frameCount = frameCount + 1;
    saveimg = rand(1) < 0.01;
    [curr_center, curr_radius, curr_area] = find_pupil(frame, true, greyVid, binVid, cleanVid, invVid, bboxVid, saveimg, frameCount);

    frame = insertShape(frame, 'Circle', [curr_center, curr_radius], ...
                        'Color', 'green', 'LineWidth', 2);

    pupilArea(frameCount) = curr_area;
    writeVideo(outputVideo, frame);
end

close(outputVideo);
close(greyVid);
close(binVid);
close(cleanVid);
close(invVid);
close(bboxVid);

relativeChange = (pupilArea - st_area) / st_area;
time = linspace(0, video.NumFrames / video.FrameRate, length(pupilArea));

figure('Name','Medições de variação da Pupila');
subplot(2,1,1);
plot(time, pupilArea, 'b', 'LineWidth', 1.5);
title('Área da Pupila');
xlabel('Tempo (s)');
ylabel('Área da Pupila (pixels)');
grid on;

subplot(2,1,2);
plot(time, relativeChange, 'r', 'LineWidth', 1.5);
title('Variação Relativa Percentual');
xlabel('Tempo (s)');
ylabel('Variação Relativa (%)');
yline(0, '--k');
grid on;

[~, videoName] = fileparts(videoFile);
imageFilename = [videoName '.png'];
saveas(gcf, imageFilename);
print(gcf, imageFilename, '-dpng', '-r300');