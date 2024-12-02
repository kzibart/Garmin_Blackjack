import Toybox.Lang;
import Toybox.WatchUi;

class BlackjackDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
                WatchUi.pushView(new BlackjackSettings(), new BlackjackMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(clickEvent) as Boolean {
        var xy = clickEvent.getCoordinates();

        switch (state) {
            case 0:
                // New round
                // Allow clear bet, if bet > 0
                if (inbox(clearXY,buttonWH,xy) and bet > 0) {
                    money += bet;
                    bet = 0;
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                // Allow bet amount buttons, if <= available money
                for (var i=0;i<betXY.size();i++) {
                    if (inbox(betXY[i],betWH[i],xy) and money>=betamt[i]) {
                        bet += betamt[i];
                        money -= betamt[i];
                        savegame();
                        WatchUi.requestUpdate();
                        return true;
                    }
                }
                // Allow deal button
                if (inbox(dealXY,buttonWH,xy) and bet>0) {
                    deal();
                    tmp = getval(0);
                    if (ace and tmp == 11) {
                        dealerturn();
                    } else { state = 1; }
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                break;
            case 1:
                // Betting done, time to play
                // Allow stand, hit, split buttons
                if (inbox(standXY,buttonWH,xy)) {
                    if (split and curhand == 0) {
                        curhand = 1;
                        hit(curhand);
                    }
                    else { dealerturn(); }
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                if (inbox(hitXY,buttonWH,xy)) {
                    hit(curhand);
                    tmp = getval(curhand);
                    if (tmp >= 21) {
                        if (split and curhand == 0) {
                            curhand = 1;
                            hit(curhand);
                        }
                        else { dealerturn(); }
                    }
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                tmp = (split == false) and (hand[0].size() == 2) and (hand[0][0].substring(0,1).equals(hand[0][1].substring(0,1))) and (money >= bet);
                if (inbox(splitXY,buttonWH,xy) and tmp) {
                    split = true;
                    money -= bet;
                    hand[1] = [hand[0][1]];
                    hand[0] = [hand[0][0]];
                    hit(0);
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                break;
            case 2:
                // Hand is done, showing results
                // Allow new button
                if (inbox(newXY,buttonWH,xy)) {
                    if (split) { tmp = getresult(1); }
                    else { tmp = getresult(0); }
                    if (tmp != 0) { push = 0; }
                    if (money == 0) {
                        state = 3;
                    } else {
                        newround();
                    }
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
                break;
            case 3:
                // Out of money, game over
                // Allow new button
                if (inbox(newXY,buttonWH,xy)) {
                    newgame();
                    WatchUi.requestUpdate();
                    return true;
                }
                break;
        }
        return false;
    }

    // Check if a point is within a box
    // boxxy = [x,y] coordinates of center of box
    // boxwh = [w,h] width and height of box
    // point = [x,y] coordinates of point to check
    function inbox(boxxy,boxwh,point) as Boolean {
        var bx = boxxy[0]-boxwh[0]/2;
        var by = boxxy[1]-boxwh[1]/2;
        if (point[0]<bx) {return false;}
        if (point[0]>bx+boxwh[0]) {return false;}
        if (point[1]<by) {return false;}
        if (point[1]>by+boxwh[1]) {return false;}
        return true;
    }
}