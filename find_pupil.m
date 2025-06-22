function [center, radius, area] = find_pupil(eyeImg)
    sensitivity = 0.000001;
    minArea = 100;
    
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
end
