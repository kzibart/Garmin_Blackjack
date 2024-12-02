import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Application.Storage;

var DS = System.getDeviceSettings();
var SW = DS.screenWidth;
var SH = DS.screenHeight;
var center = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;
var left = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;
var right = Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER;

var game,state,money,bet,push,deck,dealer,hand,curhand,split;
var moneyXY,dealerXY,handXY,split1XY,split2XY,resultXY,result1XY,result2XY,betXY,betWH,betamt,hitXY,standXY,splitXY,dealXY,newXY,clearXY;
var bigcardWH,bigcardR;
var smallcardWH,smallcardR;
var betlXY,dvalXY,hvalXY,hval1XY,hval2XY;
var solid,shadow,so,soh,buttonWH,buttonR;
var mydc,tmp,tmp2,tmp3;
var winstreak,losestreak;
var lastresult = 0;
var val,res,col;
var stats,losses,wins;
var ace = false;
var labelfont = Graphics.FONT_TINY;
var buttonfont = Graphics.FONT_XTINY;

var themes = ["Outlines", "Outlines with shadows", "Solids", "Solids with shadows"];
var theme = 3;
var backgrounds = ["Green", "Blue", "Red", "Black"];
var bgcolors = [0x204020, 0x006374, 0x7f2019, 0x000000];
var background = 0;

// greens
var green = 0x27c235;
var moneycolor = green;
var betcolor = green;
var wincolor = green;
// blues
var blue = 0x2794c2;
var standcolor = blue;
var pushcolor = blue;
// reds
//var red = 0xcc3529;
var red = 0xcc5c5c;
var hitcolor = red;
var bustcolor = red;
var losecolor = red;
// yellows
var yellow = 0xc2b528;
var newcolor = yellow;
var splitcolor = yellow;
var dealcolor = yellow;
var clearcolor = yellow;
// grays
var valcolor = 0xaaaaaa;
var shadowcolor = 0x555555;
var nopecolor = 0x808080;

var suitF,sh;

class BlackjackView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        bigcardWH = [SW*18/100,SH*27/100];
        bigcardR = bigcardWH[0]/10;
        smallcardWH = [SW*12/100,SH*18/100];
        smallcardR = smallcardWH[0]/10;

        buttonWH = [SW*25/100,SH*10/100];
        buttonR = (SW*.015).toNumber();
        so = buttonR/2;
        soh = so/2;

        // All XY values are centers
        moneyXY = [SW/2,SH*10/100];
        betlXY = [SW*20/100,SH*25/100];
        dvalXY = [SW*80/100,SH*25/100];
        dealerXY = [SW/2,SH*25/100];
        handXY = [SW/2,SH*50/100];
        resultXY = [SW/2,SH*78/100];
        hvalXY = [SW*50/100,SH*68/100];
        hval1XY = [SW*26/100,SH*68/100];
        hval2XY = [SW*74/100,SH*68/100];
        split1XY = [SW*26/100,SH*50/100];
        split2XY = [SW*74/100,SH*50/100];
        result1XY = [SW*26/100,SH*78/100];
        result2XY = [SW*74/100,SH*78/100];
        betXY = [
            [SW*22/100,SH*66/100],
            [SW*50/100,SH*66/100],
            [SW*78/100,SH*66/100],
            [SW*36/100,SH*78/100],
            [SW*64/100,SH*78/100]
        ];
        betWH = [buttonWH,buttonWH,buttonWH,buttonWH,buttonWH];
        betamt = [1,5,25,100,500];
        clearXY = [SW*50/100,SH*25/100];
        dealXY = [SW/2,SH*90/100];
        hitXY = [SW*36/100,SH*78/100];
        standXY = [SW*64/100,SH*78/100];
        splitXY = [SW/2,SH*90/100];
        newXY = [SW/2,SH*90/100];

        game = Storage.getValue("game");
        if (game == null) { newgame(); }

        if (SW < 270) { 
            suitF = WatchUi.loadResource(Rez.Fonts.suits20);
            sh = 12;
        }
        else if (SW < 360) { 
            suitF = WatchUi.loadResource(Rez.Fonts.suits30); 
            sh = 17;
        }
        else if (SW < 390) { 
            suitF = WatchUi.loadResource(Rez.Fonts.suits35); 
            sh = 20;
        }
        else {
            suitF = WatchUi.loadResource(Rez.Fonts.suits40);
            sh = 25;
        }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        mydc = dc;

        theme = Storage.getValue("theme");
        if (theme == null) { theme = 3; Storage.setValue("theme",theme); }
        switch (theme) {
            case 0:
                solid = false;
                shadow = false;
                break;
            case 1:
                solid = false;
                shadow = true;
                break;
            case 2:
                solid = true;
                shadow = false;
                break;
            case 3:
                solid = true;
                shadow = true;
                break;
        }

        background = Storage.getValue("background");
        if (background == null) { background = 0; Storage.setValue("background",background); }

        mydc.setColor(bgcolors[background],bgcolors[background]);
        mydc.clear();

        state = game.get("state");
        money = game.get("money");
        bet = game.get("bet");
        push = game.get("push");
        deck = game.get("deck");
        dealer = game.get("dealer");
        hand = game.get("hand");
        curhand = game.get("curhand");
        split = game.get("split");

        drawlabel(moneyXY,"$"+commas(money),moneycolor,true);
        switch (state) {
            case 0:
                // New round
                drawlabel([SW/2,SH*40/100],"Make Your",Graphics.COLOR_WHITE,true);
                drawlabel([SW/2,SH*50/100],"Wager",Graphics.COLOR_WHITE,true);
                // Draw bet amount
                drawlabel(betlXY,"$"+commas(bet),betcolor,false);
                // Draw push amount
                if (push > 0) {
                    drawlabel(dvalXY,"$"+commas(push),pushcolor,false);
                }
                // Draw clear button
                drawbutton(clearXY,buttonWH,"Clear",clearcolor,bet>0);
                // Draw bet buttons
                for (var i=0;i<betXY.size();i++) {
                    drawbutton(betXY[i],betWH[i],"$"+betamt[i],betcolor,money>=betamt[i]);
                }
                // Draw deal button
                drawbutton(dealXY,buttonWH,"Deal",dealcolor,bet>0);
                break;
            case 1:
                // Betting done, time to play
                // Draw dealer first card and blank card
                drawcards(dealerXY,dealer,false,true);
                // Draw bet amount
                tmp = bet;
                if (split) { tmp *= 2; }
                drawlabel(betlXY,"$"+commas(tmp),betcolor,false);
                // Draw push amount
                if (push > 0) {
                    drawlabel(dvalXY,"$"+commas(push),pushcolor,false);
                }
                // Draw hand(s)
                if (split) {
                    drawcards(split1XY,hand[0],curhand==0,false);
                    tmp = getval(0);
                    if (ace and tmp <= 11) {tmp2 = tmp+"/"+(tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hval1XY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hval1XY,tmp2,valcolor,false);
                    }
                    drawcards(split2XY,hand[1],curhand==1,false);
                    tmp = getval(1);
                    if (ace and tmp <= 11) {tmp2 = tmp+"/"+(tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hval2XY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hval2XY,tmp2,valcolor,false);
                    }
                } else {
                    drawcards(handXY,hand[0],true,false);
                    tmp = getval(0);
                    if (ace and tmp <= 11) {tmp2 = tmp+"/"+(tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hvalXY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hvalXY,tmp2,valcolor,false);
                    }
                }
                // Draw stand, hit, split buttons
                drawbutton(standXY,buttonWH,"Stand",standcolor,true);
                drawbutton(hitXY,buttonWH,"Hit",hitcolor,true);
                tmp = (split == false) and (hand[0].size() == 2) and (hand[0][0].substring(0,1).equals(hand[0][1].substring(0,1))) and (money >= bet);
                drawbutton(splitXY,buttonWH,"Split",splitcolor,tmp);
                break;
            case 2:
                // Hand is done, showing results
                // Draw dealer all cards
                drawcards(dealerXY,dealer,false,false);
                tmp = getval(2);
                if (ace and tmp <= 11) {tmp2 = (tmp+10); }
                else {tmp2 = tmp+""; }
                if (tmp > 21) {
                    drawlabel(dvalXY,tmp2,losecolor,false);
                } else {
                    drawlabel(dvalXY,tmp2,valcolor,false);
                }
                // Draw hand(s)
                if (split) {
                    drawcards(split1XY,hand[0],true,false);
                    tmp = getval(0);
                    if (ace and tmp <= 11) {tmp2 = (tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hval1XY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hval1XY,tmp2,valcolor,false);
                    }
                    drawcards(split2XY,hand[1],true,false);
                    tmp = getval(1);
                    if (ace and tmp <= 11) {tmp2 = (tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hval2XY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hval2XY,tmp2,valcolor,false);
                    }
                } else {
                    drawcards(handXY,hand[0],true,false);
                    tmp = getval(0);
                    if (ace and tmp <= 11) {tmp2 = (tmp+10); }
                    else {tmp2 = tmp+""; }
                    if (tmp > 21) {
                        drawlabel(hvalXY,tmp2,losecolor,false);
                    } else {
                        drawlabel(hvalXY,tmp2,valcolor,false);
                    }
                }
                // Draw hand results (win / lose / push / bust)
                tmp2 = 0;
                if (split) {
                    tmp = getresult(0);
                    if (tmp != 0) {
                        tmp2 += val-(bet+push);
                    }
                    drawlabel(result1XY,res,col,true);
                    tmp = getresult(1);
                    if (tmp != 0) {
                        tmp2 += val-(bet+push);
                    }
                    drawlabel(result2XY,res,col,true);
                } else {
                    tmp = getresult(0);
                    if (tmp != 0) {
                        tmp2 += val-(bet+push);
                    }
                    drawlabel(resultXY,res,col,true);
                }
                // Draw winnings
                if (tmp2 < 0) { drawlabel(betlXY,"-$"+commas(tmp2.abs()),losecolor,false); }
                else if (tmp2 == 0) { drawlabel(betlXY,"$0",pushcolor,false); }
                else { drawlabel(betlXY,"+$"+commas(tmp2),wincolor,false); }
                // Draw new button
                drawbutton(newXY,buttonWH,"New",newcolor,true);
                break;
            case 3:
                // Out of money, game over
                drawlabel([SW/2,SH*40/100],"You ran out",Graphics.COLOR_WHITE,true);
                drawlabel([SW/2,SH*50/100],"of money!",Graphics.COLOR_WHITE,true);
                // Draw new button
                drawbutton(newXY,buttonWH,"Reset",newcolor,true);
                break;
        }

    }

    function drawlabel(xy,text,col,big) {
        var myfont;
        if (big) { myfont = labelfont; }
        else { myfont = buttonfont; }
        if (shadow) {
            mydc.setColor(Graphics.COLOR_DK_GRAY,-1);
            mydc.drawText(xy[0]+so, xy[1]+so, myfont, text, center);
        }
        mydc.setColor(col,-1);
        mydc.drawText(xy[0], xy[1], myfont, text, center);
    }

    function drawbutton(xy,wh,text,col,valid) {
        var x = xy[0]-wh[0]/2;
        var y = xy[1]-wh[1]/2;
        var w = wh[0];
        var h = wh[1];
        if (solid) {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.fillRoundedRectangle(x+so, y+so, w, h, buttonR);
            }
            if (valid) {
                mydc.setColor(col,-1);
            } else {
                mydc.setColor(nopecolor,-1);
            }
            mydc.fillRoundedRectangle(x, y, w, h, buttonR);
            if (shadow) {
                mydc.setColor(Graphics.COLOR_LT_GRAY,-1);
                mydc.drawText(xy[0]-soh, xy[1]-soh, buttonfont, text, center);
            }
            mydc.setColor(Graphics.COLOR_BLACK,-1);
            mydc.drawText(xy[0], xy[1], buttonfont, text, center);
        } else {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.drawRoundedRectangle(x+so, y+so, w, h, buttonR);
                mydc.drawText(xy[0]+so, xy[1]+so, buttonfont, text, center);
            }
            if (valid) {
                mydc.setColor(col,-1);
            } else {
                mydc.setColor(nopecolor,-1);
            }
            mydc.drawRoundedRectangle(x, y, w, h, buttonR);
            mydc.drawText(xy[0], xy[1], buttonfont, text, center);
        }

    }

    function drawcards(XY as Array, cards as Array, big as Boolean, hide as Boolean) as Void {
        // layout based on nnumber of cards
        // XY is center of area to draw the cards
        // Temporarily just draw card values
        if (cards == null) { return; }
        var wh = [0,0];
        if (big) { wh = bigcardWH; }
        else { wh = smallcardWH; }
        var c = cards.size();
        var x;
        if (big) { x = XY[0]-((wh[0]*(c-1)/3)+wh[0])/2; }
        else { x = XY[0]-((wh[0]*(c-1)/2)+wh[0])/2; }
        var y = XY[1]-wh[1]/2;
        var tx = x;
        for (var i=0;i<c;i++) {
            if (hide and i == c-1) {
                drawcard(tx,y,"",big);
            } else {
                drawcard(tx,y,cards[i],big);
            }
            if (big) {
                tx += wh[0]/3;
            } else {
                tx += wh[0]/2;
            }
            
        }
    }

    function drawcard(x as Number, y as Number, val as String, big as Boolean) as Void {
        var wh,cardR;
        if (big) { wh = bigcardWH; cardR = bigcardR; }
        else { wh = smallcardWH; cardR = smallcardR; }
        var w = wh[0];
        var h = wh[1];
        var fc,tc;
        var l1 = "";
        var l2 = "";
        if (val.length() == 2) {
            l1 = val.substring(0,1);
            l2 = val.substring(1,2);
        } else {
            l1 = val;
        }
        switch (val.substring(1,2)) {
            case "s":
            case "c":
                fc = Graphics.COLOR_WHITE;
                if (solid) { tc = Graphics.COLOR_BLACK; }
                else { tc = Graphics.COLOR_WHITE; }
                break;
            case "d":
            case "h":
                fc = Graphics.COLOR_WHITE;
                tc = Graphics.COLOR_RED;
                break;
            default:
                fc = Graphics.COLOR_BLUE;
                if (solid) { tc = Graphics.COLOR_BLACK; }
                else { tc = Graphics.COLOR_WHITE; }
                break;
        }

        if (solid) {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.fillRoundedRectangle(x+so, y+so, w, h, cardR);
            }
            mydc.setColor(fc,-1);
            mydc.fillRoundedRectangle(x, y, w, h, cardR);
            mydc.setColor(Graphics.COLOR_DK_GRAY,-1);
            mydc.setPenWidth(2);
            mydc.drawRoundedRectangle(x, y, w, h, cardR);
            if (shadow) {
                mydc.setColor(Graphics.COLOR_LT_GRAY,-1);
                mydc.drawText(x+4-soh,y+sh/2+4-soh,suitF,l1,left);
                mydc.drawText(x+4-soh,y+sh/2+sh+4-soh,suitF,l2,left);
                mydc.drawText(x+w-4-soh,y+h-sh/2-4-soh,suitF,l2,right);
                mydc.drawText(x+w-4-soh,y+h-sh/2-sh-4-soh,suitF,l1,right);
            }
            mydc.setColor(tc,-1);
            mydc.drawText(x+4,y+sh/2+4,suitF,l1,left);
            mydc.drawText(x+4,y+sh/2+sh+4,suitF,l2,left);
            mydc.drawText(x+w-4,y+h-sh/2-4,suitF,l2,right);
            mydc.drawText(x+w-4,y+h-sh/2-sh-4,suitF,l1,right);
        } else {
            mydc.setPenWidth(2);
            mydc.setColor(Graphics.COLOR_BLACK,-1);
            mydc.fillRoundedRectangle(x,y,w,h,cardR);
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.drawRoundedRectangle(x+so, y+so, w, h, cardR);
                mydc.drawText(x+4+soh,y+sh/2+4+soh,suitF,l1,left);
                mydc.drawText(x+4+soh,y+sh/2+sh+4+soh,suitF,l2,left);
                mydc.drawText(x+w-4+soh,y+h-sh/2-4+soh,suitF,l2,right);
                mydc.drawText(x+w-4+soh,y+h-sh/2-sh-4+soh,suitF,l1,right);
            }
            mydc.setColor(fc,-1);
            mydc.drawRoundedRectangle(x, y, w, h, cardR);
            mydc.setColor(tc,-1);
            mydc.drawText(x+4,y+sh/2+4,suitF,l1,left);
            mydc.drawText(x+4,y+sh/2+sh+4,suitF,l2,left);
            mydc.drawText(x+w-4,y+h-sh/2-4,suitF,l2,right);
            mydc.drawText(x+w-4,y+h-sh/2-sh-4,suitF,l1,right);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}

function getresult(h as Number) as Number {
    // determine result
    // set result string, color, and winnings
    // return result: -1 = lose, 0 = push, 1 = win
    var dcards = dealer.size();
    var d = getval(2);
    if (ace and d <= 11) { d += 10; }

    var pcards = hand[h].size();
    var p = getval(h);
    if (ace and p <= 11) { p += 10; }

    if (p>21) {
        // bust
        res = "Bust";
        col = bustcolor;
        val = 0;
        return -1;
    } else if (p==21 and pcards == 2) {
        if (d==21 and dcards == 2) {
            // both naturals, so push
            res = "Push";
            col = pushcolor;
            val = 0;
            return 0;
        } else {
            // natural 21, win 1.5 times bet
            res = "21!";
            col = wincolor;
            val = ((push+bet)*2.5).toNumber();
            return 1;
        }
    } else if (p>d or d>21) {
        // standard win
        res = "Win!";
        col = wincolor;
        val = (push+bet)*2;
        return 1;
    }else if (p==d) {
        // tie / push
         res = "Push";
         col = pushcolor;
         val = 0;
         return 0;
    } else {
        // lose
        res = "Lose";
        col = losecolor;
        val = 0;
        return -1;
    }
}

function newgame() as Void {
    // brand new game (first ever or when user runs out of money)
    money = 1000;
    push = 0;
    winstreak = [0,0];
    losestreak = [0,0];
    lastresult = 0;
    newround();
    savegame();
}

function newround() as Void {
    state = 0;
    bet = 0;
    deck = ["As","2s","3s","4s","5s","6s","7s","8s","9s","Ts","Js","Qs","Ks",
            "Ac","2c","3c","4c","5c","6c","7c","8c","9c","Tc","Jc","Qc","Kc",
            "Ad","2d","3d","4d","5d","6d","7d","8d","9d","Td","Jd","Qd","Kd",
            "Ah","2h","3h","4h","5h","6h","7h","8h","9h","Th","Jh","Qh","Kh"];
    for (var i=0;i<1000;i++) {
        tmp = Math.rand() % 52;
        tmp2 = Math.rand() % 52;
        tmp3 = deck[tmp];
        deck[tmp] = deck[tmp2];
        deck[tmp2] = tmp3;
    }
    dealer = null;
    hand = null;
    curhand = 0;
    split = false;
}

function savegame() as Void {
    game = {
        "ver" => 1,
        "state" => state,
        "money" => money,
        "bet" => bet,
        "push" => push,
        "deck" => deck,
        "dealer" => dealer,
        "hand" => hand,
        "curhand" => curhand,
        "split" => split,
        "winstreak" => winstreak,
        "losestreak" => losestreak,
        "lastresult" => lastresult
    };
    Storage.setValue("game",game);
}

function deal() as Void {
    // initial deal of cards to dealer and user
    hand = [[deck[0],deck[2]],null];
    dealer = [deck[1],deck[3]];
    deck = deck.slice(4,null);
}

function hit(h as Number) as Void {
    // h = 0 for hand[0], 1 for hand[1], 2 for dealer
    if (h == 2) {
        dealer.add(deck[0]);
    } else {
        hand[h].add(deck[0]);
    }
    deck = deck.slice(1,null);
}

function getval(h as Number) as Number {
    // add up the value for the given hand
    // h = 0 for hand[0], 1 for hand[1], 2 for dealer
    // sets ace to true if there's an ace in the hand
    var c,t;
    if (h == 2) { c = dealer; }
    else { c = hand[h]; }
    var v = 0;
    ace = false;
    for (var i=0;i<c.size();i++) {
        t = value(c[i]);
        if (t == 1) { ace = true; }
        v += t;
    }
    return v;
}

function value(c as String) as Number {
    // return the value of the given card
    switch (c.substring(0,1)) {
        case "A": return 1;
        case "2": return 2;
        case "3": return 3;
        case "4": return 4;
        case "5": return 5;
        case "6": return 6;
        case "7": return 7;
        case "8": return 8;
        case "9": return 9;
        case "T": return 10;
        case "J": return 10;
        case "Q": return 10;
        case "K": return 10;
    }
    return 0;
}

function dealerturn() as Void {
    for (var i=0;i<10;i++) {
        tmp = getval(2);
        if (ace and tmp <= 11) { tmp += 10; }
        if (tmp >= 17) { break; }
        hit(2);
    }
    // Determine outcome of hand[0]
    tmp = getresult(0);
    updatestats(tmp);
    money += val;
    if (tmp == 0) { push += bet; }
    if (split) {
        // Determine outcome of hand[1]
        tmp = getresult(1);
        updatestats(tmp);
        money += val;
        if (tmp == 0) { push += bet; }
    }
    state = 2;
}

function commas(whole) {
    if (whole == 0) { return "0"; }
    var digits = [];
    
    var count = 0;
    while (whole != 0) {
        var digit = (whole % 10).toString();
        whole /= 10;
        
        if (count == 3) {
            digits.add(",");
            count = 0;
        }
        ++count;
        
        digits.add(digit);
    }
    
    digits = digits.reverse();
    
    whole = "";
    for (var i = 0; i < digits.size(); ++i) {
        whole += digits[i];
    }

    return whole;
}

function updatestats(r as Number) as Void {
    stats = Storage.getValue("stats");
    if (stats == null) {
        // [count, streak count, streak amount]
        stats = {
            "wins" => [0,0,0],
            "losses" => [0,0,0]
        };
    }
    wins = stats.get("wins");
    losses = stats.get("losses");
    switch (r) {
        case 0:
            break;
        case 1:
            if (lastresult == 1) {
                winstreak[0]++;
                winstreak[1] += bet;
            } else { winstreak = [1,bet]; }
            wins[0]++;
            if (winstreak[0] > wins[1]) { wins[1] = winstreak[0]; }
            if (winstreak[1] > wins[2]) { wins[2] = winstreak[1]; }
            lastresult = 1;
            break;
        case -1:
            if (lastresult == -1) {
                losestreak[0]++;
                losestreak[1] += bet;
            } else { losestreak = [1,bet]; }
            losses[0]++;
            if (losestreak[0] > losses[1]) { losses[1] = losestreak[0]; }
            if (losestreak[1] > losses[2]) { losses[2] = losestreak[1]; }
            lastresult = -1;
            break;
    }
    stats.put("wins",wins);
    stats.put("losses",losses);
    Storage.setValue("stats",stats);
}

function showstats() {
    var stats = Storage.getValue("stats") as Dictionary;
    if (stats == null) { return; }
    var menu = new WatchUi.CustomMenu(40*SH/454, Graphics.COLOR_BLACK,{
        :title => new $.DrawableMenuTitle(),
        :titleItemHeight => 70*SH/454
    });
    var w = stats.get("wins");
    var l = stats.get("losses");
    var t = w[0]+l[0];
    var wp = w[0]*100/t;
    var lp = l[0]*100/t;
    menu.addItem(new $.CustomItem(0,"Wins",commas(w[0])));
    menu.addItem(new $.CustomItem(0,"Win Pct",wp+"%"));
    menu.addItem(new $.CustomItem(0,"Streak Cnt",w[1]));
    menu.addItem(new $.CustomItem(0,"Streak Amt","$"+commas(w[2])));
    menu.addItem(new $.CustomItem(1,"Losses",commas(l[0])));
    menu.addItem(new $.CustomItem(1,"Loss Pct",lp+"%"));
    menu.addItem(new $.CustomItem(1,"Streak Cnt",l[1]));
    menu.addItem(new $.CustomItem(1,"Streak Amt","$"+commas(l[2])));
    WatchUi.pushView(menu, new $.BlackjackStatsDelegate(), WatchUi.SLIDE_UP);
    WatchUi.requestUpdate();
}

class BlackjackStatsDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
        return;
    }

    public function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DrawableMenuTitle extends WatchUi.Drawable {
    public function initialize() {
        Drawable.initialize({});
    }
    
    public function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(dc.getWidth()/2,(dc.getHeight()*.7).toNumber(),Graphics.FONT_SMALL,"Statistics",center);
        dc.setPenWidth(3);
        dc.drawLine(0,dc.getHeight(),dc.getWidth(),dc.getHeight());
    }
}

class CustomItem extends WatchUi.CustomMenuItem {
    private var _id as Number;
    private var _label as String;
    private var _value as String;

    public function initialize(id as Number, label as String, value as String) {
        CustomMenuItem.initialize(id, {});
        _id = id;
        _label = label;
        _value = value;
    }

    public function draw(dc as Dc) as Void {
        // Fill background horizontally based on percentage
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bx = w/8;
        var bw = w*6/8;
        var lx = bx;
        var vx = bx+bw;
        if (_id == 0) { dc.setColor(wincolor,-1); }
        else { dc.setColor(losecolor,-1); }
        dc.drawText(lx,h/2,Graphics.FONT_TINY,_label,left);
//        dc.setColor(valcolor,-1);
        dc.drawText(vx,h/2,Graphics.FONT_TINY,_value,right);
    }
}

class BlackjackSettings extends WatchUi.Menu2 {
    public function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        var themeicon = new $.CustomIcon(theme);
        var bgicon = new $.CustomIcon(background);
        var statsicon = new $.CustomIcon(0);

        Menu2.addItem(new WatchUi.IconMenuItem("Theme", themes[theme], "theme", themeicon, null));
        Menu2.addItem(new WatchUi.IconMenuItem("Background", backgrounds[background], "background", bgicon, null));
        Menu2.addItem(new WatchUi.IconMenuItem("Stats", "Show statistics", "stats", statsicon, null));
    }
}

class CustomIcon extends WatchUi.Drawable {
    private var _index as Number;

    public function initialize(index as Number) {
        _index = index;
        Drawable.initialize({});
    }

    public function draw(dc as Dc) as Void {
        dc.setColor(-1,-1);
        dc.clear();
    }
}
