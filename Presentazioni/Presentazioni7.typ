#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#show raw.where(block: true, lang: none): it => raw(it.text, lang: "cpp", block: true)
#show raw.where(lang: "cpp"): set text(size: 0.65em)
#let size(s, body) = {
  show raw: set text(size: s)
  body
}

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 6",
  date: "1 dicembre 2026",
)

#filled-slide[
  I principi SOLID
]

#slide(title: "Modalità 1")[
  #show raw: set text(size: 2em)

  ```cpp
  template<class T>
  class base { ... };

  class derivata : public base<int> { ... };
  ```
  \ \
  Ogni oggetto della classe _derivata_ contiene come sottooggetto un oggetto dell'istanza base\<int\> della classe template _base_
]

