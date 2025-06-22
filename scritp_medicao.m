clc; clear; close all;

videoFile = 'pupil01.mp4';
outputVideoFile = strcat('_', strrep(videoFile,'.mp4','_circle.mp4'));

video = VideoReader(videoFile);
firstFrame = readFrame(video);

[center, ~, st_area] = find_pupil(firstFrame);


pupilArea = [video.NumFrames];
frameCount = 0;

video = VideoReader(videoFile); 

outputVideo = VideoWriter(outputVideoFile, 'MPEG-4');
outputVideo.FrameRate = video.FrameRate;
open(outputVideo);

while hasFrame(video)
    frame = readFrame(video);
    frameCount = frameCount + 1;

    [curr_center, curr_radius, curr_area] = find_pupil(frame);

    frame = insertShape(frame, 'Circle', [curr_center, curr_radius], ...
                        'Color', 'green', 'LineWidth', 2);

    pupilArea(frameCount) = curr_area;
    writeVideo(outputVideo, frame);
end

close(outputVideo);

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