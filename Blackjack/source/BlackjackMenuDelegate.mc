import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class BlackjackMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
        switch (item.getId()) {
            case "theme":
                theme = (theme + 1) % themes.size();
                Storage.setValue("theme",theme);
                item.setSubLabel(themes[theme]);
                break;
            case "background":
                background = (background + 1) % backgrounds.size();
                Storage.setValue("background",background);
                item.setSubLabel(backgrounds[background]);
                break;
            case "stats":
                showstats();
                break;
        }
    }

    public function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }


}