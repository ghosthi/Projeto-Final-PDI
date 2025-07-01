function [center, radius, area] = find_pupil(eyeImg, saveVid, grayVid, binVid, cleanVid, invVid, bboxVid, saveImg, frameCount)
    sensitivity = 0.000001;
    minArea = 2000;
    
    grayImg = rgb2gray(eyeImg);
    
    binary = imbinarize(grayImg, 'adaptive', ...
                       'Sensitivity', sensitivity, ...
                       'ForegroundPolarity', 'dark');
    
    cleaned = bwareaopen(binary, minArea);

    inverted = imcomplement(cleaned);
    
    [labeled, ~] = bwlabel(inverted);
    stats = regionprops(labeled, 'Area', 'Centroid', 'Image', 'BoundingBox');
    
    [height, width, ~] = size(eyeImg);
    fcenter = [width/2, height/2];
    
    maxWeightedScore = -Inf;
    [~, idx] = max([stats.Area]);
    
    for k = 1:length(stats)
        area = stats(k).Area;
        c = stats(k).Centroid;

        dist = sqrt((c(1) - fcenter(1))^2 + (c(2) - fcenter(2))^2);
        
        normalizedArea = (area - min([stats.Area])) / (max([stats.Area]) - min([stats.Area]));
        normalizedDistance = 1 - (dist / max(width, height));
        
        weightedScore = 0.3 * normalizedArea + 0.7 * normalizedDistance;
        
        if weightedScore > maxWeightedScore && ...
                area > minArea && ...
                c(1) > fcenter(1)
            maxWeightedScore = weightedScore;
            idx = k;
        end
    end

    pupilRegion = stats(idx);
    
    center = [pupilRegion.BoundingBox(1)+(pupilRegion.BoundingBox(3)/2), ...
             pupilRegion.BoundingBox(2)+(pupilRegion.BoundingBox(4)/2)];
    radius = mean([pupilRegion.BoundingBox(3), pupilRegion.BoundingBox(4)]) / 2;
    area = pi * (radius ^ 2);

    bboxesImg = im2uint8(inverted);
    for k = 1:length(stats)
        bboxesImg = insertShape(bboxesImg, 'rectangle', stats(k).BoundingBox, ...
                    'Color', 'green', 'LineWidth', 2);
    end
    if nargin > 1 && saveVid
        writeVideo(grayVid, grayImg);
        writeVideo(binVid, im2uint8(binary));
        writeVideo(cleanVid, im2uint8(cleaned));
        writeVideo(invVid, im2uint8(inverted));
        writeVideo(bboxVid, bboxesImg);
    end

    if nargin > 7 && saveImg && saveVid
        baseFilename = sprintf('/img/pupil_detection_%d', frameCount);
        
        imwrite(eyeImg, [baseFilename '_original.png']);
        
        imwrite(grayImg, [baseFilename '_gray.png']);
        imwrite(binary, [baseFilename '_binary.png']);
        imwrite(cleaned, [baseFilename '_cleaned.png']);
        imwrite(inverted, [baseFilename '_inverted.png']);
        imwrite(bboxesImg, [baseFilename '_bboxes.png']);
    end
end
