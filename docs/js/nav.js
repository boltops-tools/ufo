function onlyShow(className) {
    $("ul.build-scratch").hide();
    $("ul.build-new").hide();
    $("ul.build-existing").hide();
    if (className) {
        $("ul." + className).show();
    }
}

$( document ).ready(function() {
    // onlyShow(); // hides all level 2 links

    var currentPath = $(location).attr('pathname');

    // add active class to the subnav link based on the current page
    var activeLink = $(".content-nav a").filter(function(i, link) {
      return(link.pathname == currentPath);
    });
    activeLink.addClass("active");

    // hide level 2 list items unless currently under that area
    // if (~currentPath.indexOf("/docs/scratch")) {
    //     console.log("scratch");
    //     onlyShow("build-scratch");
    // } else if (~currentPath.indexOf("/docs/new")) {
    //     console.log("new");
    //     onlyShow("build-new");
    // } else if (~currentPath.indexOf("/docs/existing")) {
    //     console.log("existing");
    //     onlyShow("build-existing");
    // }

    var keymap = {};

    // LEFT
    keymap[ 37 ] = "#prev";
    // RIGHT
    keymap[ 39 ] = "#next";

    $( document ).on( "keyup", function(event) {
        var href,
            selector = keymap[ event.which ];
        // if the key pressed was in our map, check for the href
        if ( selector ) {
            href = $( selector ).attr( "href" );
            if ( href ) {
                // navigate where the link points
                window.location = href;
            }
        }
    });

});
