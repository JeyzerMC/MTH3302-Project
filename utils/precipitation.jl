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

function mean_wo_missing(col)
    mean = 0;

    for i=1:size(col, 1)
        if !isequal(col[i, 1], missing)
            mean += col[i, 1]
        end
    end
    mean = mean ÷ size(col, 1)
    return mean;
end

function convert_meteo(meteo)
    if meteo == "Bellevue"
        return 0
    elseif meteo == "Trudeau"
        return 1
    elseif meteo == "McTavish"
        return 2
    elseif meteo == "StHubert"
        return 3
    else
        return 4
    end
end