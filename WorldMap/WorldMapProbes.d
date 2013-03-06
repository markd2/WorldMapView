provider BNRWorldMap {
    probe country_draw (char *, int, int, int); /* country code, red, green, blue */
    probe country_clicked (char *);
};