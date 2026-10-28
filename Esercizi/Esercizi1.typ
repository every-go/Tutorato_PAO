#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *

#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 1 - Esercizi Extra",
  date: "20 Ottobre 2026",
)

// --- EXTRA 1: cosa stampa ---
#slide(title: "Extra 1: cosa stampa?")[
  #align(left)[
    #show raw: set text(size: 0.75em)
    ```cpp
    #include <iostream>
    using namespace std;

    class A {
      int y;
      int x;
    public:
      A(int v) : x(v), y(x + 2) {}
      void print() { cout << "x=" << x << ", y=" << y << endl; }
    };

    int main() {
      A a(5);
      a.print();
      return 0;
    }
    ```
  ]
  *Quale comportamento ci si aspetta e cosa potrebbe stampare `a.print()`?*
]

#slide(title: "Extra 1: soluzione")[
  #align(left)[
    #show raw: set text(size: 0.75em)
    ```
    Output: x=5, y=<valore_spazzatura_o_undefined>
    ```
  ]
  *Spiegazione:*
  In C++, i membri di una classe vengono inizializzati *nell'ordine in cui sono dichiarati nella classe*, non nell'ordine della lista di inizializzazione!
  - Nella dichiarazione, `y` viene prima di `x`.
  - Quindi viene inizializzato prima `y = x + 2` quando `x` non è ancora stato inizializzato (valore indefinito/spazzatura).
  - Subito dopo viene inizializzato `x = 5`.
]

// --- EXTRA 2: COMPLETAMENTO ---
#slide(title: "Extra 2")[
  Completa le parti mancanti (`/* 1 */`, `/* 2 */`, `/* 3 */`) dell'operatore di assegnazione della seguente classe `Buffer`:
  #align(left)[
    #show raw: set text(size: 0.7em)
    ```cpp
    class Buffer {
      int* data;
      int size;
    public:
      Buffer& operator=(const Buffer& b) {
        if ( /* 1 */ ) {
          /* 2 */;
          size = b.size;
          data = new int[size];
          for(int i = 0; i < size; ++i) data[i] = b.data[i];
        }
        return /* 3 */;
      }
    };
    ```
  ]
]

#slide(title: "Extra 2: soluzione")[
  #align(left)[
    #show raw: set text(size: 0.75em)
    ```cpp
    /* 1 */ this != &b
    /* 2 */ delete[] data
    /* 3 */ *this
    ```
  ]
  *Spiegazione:*
  - `/* 1 */`: controllo dell'auto-assegnazione (`this != &b`) per evitare di cancellare la memoria dell'oggetto stesso.
  - `/* 2 */`: libera il vecchio array allocato dinamicamente con `delete[] data`.
  - `/* 3 */`: ritorna l'oggetto corrente per riferimento (`*this`) per consentire la concatenazione (`b1 = b2 = b3`).
]

// --- EXTRA 3: cosa stampa ---
#slide(title: "Extra 3: cosa stampa?")[
  #align(left)[
    #show raw: set text(size: 0.75em)
    ```cpp
    #include <iostream>
    using namespace std;

    class Item {
      char id;
    public:
      Item(char i) : id(i) { cout << "+" << id << " "; }
      ~Item() { cout << "-" << id << " "; }
    };

    int main() {
      Item a('A');
      {
        Item b('B');
        static Item c('C');
      }
      Item d('D');
      return 0;
    }
    ```
  ]
  *cosa stampa a schermo l'esecuzione del programma?*
]

#slide(title: "Extra 3: soluzione")[
  #align(left)[
    #show raw: set text(size: 0.75em)
    ```
    Output: +A +B +C -B +D -D -A -C
    ```
  ]
  *Spiegazione:*
  1. `Item a('A');` -> `+A`
  2. Entra nel blocco: `Item b('B');` -> `+B`, `static Item c('C');` -> `+C`.
  3. Esce dal blocco: `b` viene distrutta -> `-B`. L'oggetto `c` è `static`, quindi vive fino alla fine del programma!
  4. `Item d('D');` -> `+D`.
  5. Fine del `main`: vengono distrutti in ordine inverso di stack gli oggetti locali `d` (`-D`) e `a` (`-A`).
  6. Infine viene distrutto l'oggetto `static c` (`-C`).
]

// Blocco di codice allineato a sinistra e con dimensione ridotta
#let code(body, size: 0.8em) = {
  show raw: set text(size: size)
  align(left, body)
}

// ---------- Codice degli esercizi ----------

#let x1 = ```cpp
class D{
  private: int id;
  public:
    D(int i): id(i){ cout << "C" << id << " "; }
    ~D(){ cout << "D" << id << " "; }
};

int main(){
  D a(1);
  {
    D b(2);
    D c(3);
  }
  D d(4);
  cout << "fine ";
}
```

#let x2 = ```cpp
class Acc{
  private: int tot;
  public:
    Acc(): tot(0) {}
    Acc& add(int x){ tot += x; return *this; }
    Acc addCopy(int x){ tot += x; return *this; }
    int get() const { return tot; }
};

int main(){
  Acc a;
  a.add(1).add(2).add(3);
  cout << a.get() << endl;

  Acc b;
  b.addCopy(1).addCopy(2).addCopy(3);
  cout << b.get() << endl;
}
```

#let x3-h = ```cpp
// rect.h
class Rect{
  private:
    double w, h;
  public:
    Rect(double w_in = 1, double h_in = 1);
    double area() const;
    Rect& scale(double k);
};
```

#let x3-cpp = ```cpp
// rect.cpp
______::Rect(double w_in, double h_in): ______ {}

double Rect::area() ______ {
  return w * h;
}

______ Rect::scale(double k){
  w *= k;
  h *= k;
  return ______;
}
```

#let x3-cpp-sol = ```cpp
// rect.cpp
Rect::Rect(double w_in, double h_in): w(w_in), h(h_in) {}

double Rect::area() const {
  return w * h;
}

Rect& Rect::scale(double k){
  w *= k;
  h *= k;
  return *this;
}
```

#let x4 = ```cpp
class Box{
  public:
    int* p;
    Box(int x): p(new int(x)) {}
};

int main(){
  Box a(5);
  Box b = a;
  *b.p = 9;
  cout << *a.p << " " << *b.p << endl;
}
```

#let x4-fix = ```cpp
class Box{
  public:
    int* p;
    Box(int x): p(new int(x)) {}
    Box(const Box& o): p(new int(*o.p)) {}
};
```

#let x5 = ```cpp
class M{
  public:
    M(int x){ cout << "int "; }
    M(double x){ cout << "double "; }
    M(int x, int y){ cout << "two "; }
};

int main(){
  M a(3);
  M b(3.5);
  M c(1, 2);
  M d = 4;
}
```

#let x6 = ```cpp
class Money{
  private: int euro;
  public:
    Money(int e = 0): euro(e) {}

    ______ operator+=(const Money& m){
      euro += m.euro;
      return ______;
    }

    int get() const { return euro; }
};

int main(){
  Money a(5), b(3);
  (a += b) += b;
  cout << a.get() << endl;
}
```

#let x7 = ```cpp
namespace A{
  int x = 1;
  void f(){ cout << "A::f " << x << endl; }
}
namespace B{
  int x = 2;
  void f(){ cout << "B::f " << x << endl; }
}

int main(){
  A::f();
  B::f();
  using namespace B;
  cout << x << " " << A::x << endl;
}
```

// Extra 1: ordine di costruzione e distruzione
#slide(title: "Extra 4: cosa stampa?")[
  Il costruttore stampa `C` seguito dall'id, il distruttore stampa `D` seguito dall'id.
  #code(x1, size: 0.85em)
]

#slide(title: "Extra 4: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Output:*
      ```text
      C1 C2 C3 D3 D2 C4 fine D4 D1
      ```
    ],
    [
      - Gli oggetti locali vengono distrutti all'uscita dal loro blocco, in ordine *inverso* rispetto alla costruzione
      - `c` e `b` muoiono alla chiusura del blocco interno (`D3 D2`)
      - `d` e `a` muoiono alla fine del `main`, dopo "fine" (`D4 D1`)
    ],
  )
]

// Extra 2: ritorno per riferimento o per valore
#slide(title: "Extra 5: cosa stampa?")[
  #code(x2, size: 0.85em)
]

#slide(title: "Extra 5: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Output:*
      ```text
      6
      1
      ```
    ],
    [
      - `add` ritorna `Acc&`: ogni chiamata della catena agisce sempre sullo stesso oggetto `a`
      - `addCopy` ritorna per valore: solo la prima chiamata modifica `b`, le successive modificano una copia temporanea
    ],
  )
]

// Extra 3: completamento header / cpp
#slide(title: "Extra 6: completa")[
  Completa il file .cpp a partire dall'header.
  #grid(
    columns: (44%, 52%),
    column-gutter: 4%,
    code(x3-h, size: 0.8em),
    code(x3-cpp, size: 0.8em),
  )
]

#slide(title: "Extra 6: soluzione")[
  #grid(
    columns: (52%, 44%),
    column-gutter: 4%,
    code(x3-cpp-sol, size: 0.8em),
    [
      - Il costruttore si definisce con `Rect::Rect` e inizializza i campi nella lista di inizializzazione
      - `area` non modifica l'oggetto: `const` va ripetuto anche nella definizione
      - `scale` ritorna `Rect&` e `*this`, così si può concatenare
      - I valori di default compaiono *solo* nella dichiarazione, non nella definizione
    ],
  )
]

// Extra 4: copia superficiale
#slide(title: "Extra 7: cosa stampa?")[
  #code(x4, size: 0.85em)
]

#slide(title: "Extra 7: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Output:*
      ```text
      9 9
      ```
      Il costruttore di copia di default copia il puntatore, non l'intero a cui punta. Come si corregge?
      #code(x4-fix, size: 0.75em)
    ],
    [
      - `a.p` e `b.p` puntano alla stessa memoria: è una copia *superficiale*
      - Nel costruttore di copia ridefinito si alloca un nuovo intero con lo stesso valore (copia *profonda*)
      - Con un distruttore che fa `delete p`, la stessa memoria verrebbe liberata due volte
    ],
  )
]

// Extra 5: overloading e conversioni implicite
#slide(title: "Extra 8: cosa stampa?")[
  #code(x5, size: 0.85em)
  Cosa cambia se il primo costruttore diventa `explicit M(int x)`?
]

#slide(title: "Extra 8: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Output:*
      ```text
      int double two int
      ```
      Con `explicit M(int x)`:
      ```text
      int double two double
      ```
    ],
    [
      - `M a(3)`: corrispondenza esatta con `M(int)`
      - `M b(3.5)`: corrispondenza esatta con `M(double)`
      - `M c(1, 2)`: `M(int, int)`
      - `M d = 4;` usa una conversione implicita: `M(int)`
      - Con `explicit`, la conversione implicita non è più possibile con `M(int)`; resta `M(double)` (da `int` a `double`)
    ],
  )
]

// Extra 6: completamento + cosa stampa
#slide(title: "Extra 9: completa e stampa")[
  Completa gli spazi e dì cosa stampa il programma.
  #code(x6, size: 0.8em)
]

#slide(title: "Extra 9: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Completamento:*
      - tipo di ritorno: `Money&`
      - valore ritornato: `*this`

      *Output:*
      ```text
      11
      ```
    ],
    [
      - `a += b` modifica `a` (8) e ritorna `a` stesso, per riferimento
      - il secondo `+= b` agisce ancora su `a`: 8 + 3 = 11
      - Se il ritorno fosse per valore, il secondo `+=` agirebbe su una copia temporanea e `a` varrebbe 8
    ],
  )
]

// Extra 7: namespace
#slide(title: "Extra 10: cosa stampa?")[
  #code(x7, size: 0.85em)
]

#slide(title: "Extra 10: soluzione")[
  #grid(
    columns: (46%, 50%),
    column-gutter: 4%,
    [
      *Output:*
      ```text
      A::f 1
      B::f 2
      2 1
      ```
    ],
    [
      - `A::f()` e `B::f()` sono due funzioni diverse, scelte con l'operatore di scoping
      - Dopo `using namespace B;`, `x` indica `B::x` (2)
      - `A::x` va comunque qualificato, perché `A` non è stato importato (1)
    ],
  )
]