using Random, Dates;

function findDistance(oLat, oLng, sLat, sLng)
    lat = (sLat - oLat) ^ 2;
    lng = (sLng - oLng) ^ 2;

    return sqrt(lat + lng);
end

function normalize(val, min, max) 
    return (val - min) / (max - min);
end

function shuffleDf(df)
    sample_test = df[shuffle(1:size(df, 1)),:]
end

function dateToDay(dt)
    return year(dt) * 365 + month(dt) * 30 + day(dt);
end 


function maximum3(col)
    maxP = 0;

    for i=1:(size(col, 1) - 2)
        p3h = col[i, 1] + col[i + 1, 1] + col[i + 2, 1]

        if p3h > maxP
            maxP = p3h
        end
    end
    return maxP;
end