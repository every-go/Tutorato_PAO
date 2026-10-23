#import "@preview/polylux:0.4.0": *
#import "./../../unipd.typ": *

#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 1",
  date: "20 Ottobre 2026",
)

#slide(title: "Esempio di classe")[
  #align(left)[
    #show raw: set text(size: 0.6em)
    ```cpp
    class Triangle{
      private:
        double a, b, c;
      public:
        Triangle(double a_in, double b_in, double c_in);
        void setTriangle(double x, double y, double z);
    };
    ```
  ]
  Ogni metodo possiede un parametro implicito _\*this_ che indica l'oggetto che invoca il metodo (oggetto di invocazione). Fatta eccezione per un metodo segnato con la keyword _static_.

  La classe è un ADT (tipo di dato astratto): definisce un dato e le operazioni che si possono fare su di esso.
]