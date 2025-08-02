-- SCRIPT BY ADA_FUNNI
-- Do not remove this watermark, or you have zero rights to use this script.

local a=20;local b=20;local c=20;local d=0.1;function onUpdatePost()if mustHitSection and getProperty('boyfriend.animation.curAnim')=='idle'then runTimer('move it back',d)elseif not mustHitSection and getProperty('dad.animation.curAnim')=='idle'then runTimer('move it back',d)end end

local function e(f) cameraSetGF() if f==0 then setProperty('camFollow.x',getProperty('camFollow.x')-c)elseif f==1 then setProperty('camFollow.y',getProperty('camFollow.y')+c)elseif f==2 then setProperty('camFollow.y',getProperty('camFollow.y')-c)elseif f==3 then setProperty('camFollow.x',getProperty('camFollow.x')+c)end end

function goodNoteHit(g,h,i,j) if mustHitSection then if not gfSection then cameraSetTarget('boyfriend')if h==0 then setProperty('camFollow.x',getProperty('camFollow.x')-b)elseif h==1 then setProperty('camFollow.y',getProperty('camFollow.y')+b)elseif h==2 then setProperty('camFollow.y',getProperty('camFollow.y')-b)elseif h==3 then setProperty('camFollow.x',getProperty('camFollow.x')+b)end else e(h)end end end

function cameraSetGF() setProperty('camFollow.x',getMidpointX('gf')+getProperty('gf.cameraPosition[0]')+getProperty('girlfriendCameraOffset[0]')) setProperty('camFollow.y',getMidpointY('gf')+getProperty('gf.cameraPosition[1]')+getProperty('girlfriendCameraOffset[1]')) end

function opponentNoteHit(k,h,i,j) if not mustHitSection then if not gfSection then cameraSetTarget('dad')if h==0 then setProperty('camFollow.x',getProperty('camFollow.x')-a)elseif h==1 then setProperty('camFollow.y',getProperty('camFollow.y')+a)elseif h==2 then setProperty('camFollow.y',getProperty('camFollow.y')-a)elseif h==3 then setProperty('camFollow.x',getProperty('camFollow.x')+a)end else e(h)end end end

function onTimerCompleted(l,m,n) if l=='move it back'then if mustHitSection then if gfSection then cameraSetGF()else cameraSetTarget('boyfriend')end else cameraSetTarget('dad')end end end