#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#show raw.where(block: true, lang: none): it => raw(it.text, lang: "cpp", block: true)
#show raw.where(lang: "cpp"): set text(size: 0.6em)
#let size(s, body) = {
  show raw: set text(size: s)
  body
}

#let nodo(n, new: false) = box(
  width: 1.5em, height: 1.5em, radius: 50%, stroke: 0.7pt,
  fill: if new { rgb("#ffd966") } else { white },
  align(center + horizon, str(n)),
)
#let ar = [#h(0.2em)#sym.arrow.l.r.double#h(0.2em)]
#let vuota = text(style: "italic")[lista vuota]

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 4",
  date: "10 Novembre 2026",
)

#slide(title: "L'esercizio: dList<T>")[
  Lista doppiamente concatenata con:

  - gestione della memoria *senza condivisione* (big 3)
  - costruttore `dList(unsigned int k, const T& t)`
  - `insertFront` e `insertBack` in *O(1)*
  - `operator<` con ordinamento *lessicografico*
  - `const_iterator` (con l'iteratore past-the-end)

  #v(0.5em)
  Oggi: *due soluzioni* a confronto, quali idee cambiano e perché.
]

#slide(title: "Cosa hanno in comune")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *Struttura*

      - classe annidata privata `nodo` con `info`, `prev`, `next`
      - puntatori `first` e `last`
      - lista vuota #sym.arrow.l.r.double `first == last == nullptr`
    ],
    [
      *Inserimento in coda, O(1)*

      ```cpp
      void insertBack(const T& t) {
        nodo* n = new nodo(t, last, nullptr);
        if(last) last->next = n;
        else first = n;
        last = n;
      }
      ```
    ],
  )

  Avere `last` è ciò che rende O(1) anche `insertBack`.
]

#slide(title: "Confronto: le cinque idee")[
  + Come rappresentare il *past-the-end*
  + I *casi limite* dell'iteratore
  + *Ricorsione* o *cicli* nelle funzioni di appoggio
  + Cosa richiediamo al tipo `T` (`==`? costruttore di default?)
  + L'ordine delle operazioni in `operator=`

  #v(0.5em)
  *Soluzione A* (riferimento) e *Soluzione B* (variante).
]

#slide(title: "Idea 1: il past-the-end")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *Soluzione A*: puntatore "oltre" l'ultimo

      ```cpp
      end() {
        return const_iterator(last+1, true);
      }
      ```
      `++` sull'ultimo nodo fa `++ptr`, `--` da end fa `--ptr`.
    ],
    [
      *Soluzione B*: flag sul nodo finale

      ```cpp
      end() {
        return const_iterator(last, true);
      }
      ```
      `++` sull'ultimo nodo accende `past_the_end`, `--` da end lo spegne.
    ],
  )
]

#slide(title: "Idea 1: i dettagli")[
  #size(0.55em)[
    #grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      [
        *A*

        ```cpp
        const_iterator& operator++() {
          if(ptr && !pte) {
            if(ptr->next == nullptr)
              {++ptr; pte = true;}
            else ptr = ptr->next;
          }
          return *this;
        }
        ```
      ],
      [
        *B*

        ```cpp
        const_iterator& operator++() {
          if(iter && !past_the_end) {
            if(iter->next) iter = iter->next;
            else past_the_end = true;
          }
          return *this;
        }
        ```
      ],
    )
  ]

  - A ha un puntatore a un singolo oggetto che può avanzare di uno (one-past-the-end) e poi tornare indietro, ma `ptr` non punta più a un nodo, e bisogna ricordarsi che `pte` lo protegge
  - B non fa aritmetica sui puntatori: `iter` punta sempre a un nodo vero
]

#slide(title: "Idea 2: il codice di --, begin() e end()")[
  #size(0.5em)[
    #grid(
      columns: (1fr, 1fr),
      gutter: 1em,
      [
        *A*

        ```cpp
        const_iterator& operator--() {
          if(ptr) {
            if(pte) {--ptr; pte = false;}
            else ptr = ptr->prev;
          }
          return *this;
        }

        const_iterator begin() const {
          if(!first) return const_iterator();
          return const_iterator(first);
        }
        const_iterator end() const {
          if(!first) return const_iterator();
          return const_iterator(last+1, true);
        }
        ```
      ],
      [
        *B*

        ```cpp
        const_iterator& operator--() {
          if(iter) {
            if(past_the_end) past_the_end = false;
            else if(iter->prec) iter = iter->prec;
          }
          return *this;
        }

        const_iterator begin() const {
          if(!first) return const_iterator();
          return const_iterator(first);
        }
        const_iterator end() const {
          if(!first) return const_iterator();
          return const_iterator(last,true);
        }
        ```
      ],
    )
  ]

  - A: su `begin()`, `ptr = ptr->prev` porta a `nullptr` e l'iteratore diventa "indefinito"
  - B: l'`else if(iter->prec)` fa restare l'iteratore su `begin()`
]

#slide(title: "Idea 2: il codice di * e ->")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *A*: segnala l'errore

      ```
      const T& operator*() const {
        if(pte) {
          const T* p = nullptr;
          return *p;
        }
        return ptr->info;
      }

      const T* operator->() const {
        if(pte) return nullptr;
        return &(ptr->info);
      }
      ```
    ],
    [
      *B*: nessun controllo

      ```
      const T& operator*() const {
        return iter->info;
      }

      const T* operator->() const {
        return &(iter->info);
      }

      bool is_valid() const {
        return iter != nullptr
            && !past_the_end;
      }
      ```
    ],
  )

  - A: `*end()` fallisce in modo evidente, `end()->` dà `nullptr`
  - B: `*end()` restituisce l'ultimo elemento senza avvisare, quindi il controllo spetta a chi chiama (`is_valid()`)
]

#slide(title: "operator->: come funziona")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *Con un puntatore*

      ```cpp
      Punto* p = ...;
      p->x;       // uguale a (*p).x
      ```

      *Vogliamo lo stesso con l'iteratore*

      ```cpp
      auto it = l.begin();
      (*it).x;    // operator*
      it->x;      // operator->
      ```
    ],
    [
      *Cosa fa il compilatore*

      ```cpp
      it->x
      // diventa
      (it.operator->())->x
      ```

      *Quindi la funzione restituisce un puntatore*

      ```cpp
      const T* operator->() const {
        return &(iter->info);
      }
      ```
    ],
  )

  #v(0.5em)
  `operator->` non accede al campo: restituisce un *puntatore all'elemento*, e il compilatore ci riapplica `->x`.\
  Non sarà utilizzato per tutti i tipi T, ad esempio non si può utilizzare sul tipo *int*.
]

#slide(title: "Idea 2: i casi limite")[
  #size(0.9em)[
    #table(
      columns: (auto, 1fr, 1fr),
      inset: 0.5em,
      [*Situazione*], [*A*], [*B*],
      [`--begin()`], [`ptr` diventa `nullptr`: iteratore "indefinito"], [resta su `begin()`],
      [lista vuota], [`begin()` e `end()`: `(nullptr, false)`], [`begin()` e `end()`: `(nullptr, true)`],
      [`*end()`], [si dereferenzia `nullptr`], [restituisce l'ultimo elemento],
      [`end()->`], [restituisce `nullptr`], [punta all'ultimo elemento],
    )
  ]
  In entrambe dereferenziare `end()` è un errore. In A si nota subito (crash), in B passa in silenzio: per questo B ha `is_valid()` per controllare prima di dereferenziare.
]

#slide(title: "Idea 3: ricorsione o cicli")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *A*: ricorsiva

      ```cpp
      static void distruggi(nodo* p) {
        if(p) {
          distruggi(p->next);
          delete p;
        }
      }
      ```
    ],
    [
      *B*: iterativa

      ```cpp
      static void distruggi(nodo* p) {
        while(p) {
          nodo* s = p->next;
          delete p;
          p = s;
        }
      }
      ```
    ],
  )

  - la ricorsione usa *stack proporzionale alla lunghezza* della lista: con liste molto lunghe può esaurirlo
  - la versione ricorsiva è però più breve e vicina alla definizione induttiva
]

#slide()[
  \
  *A*: ricorsiva

  ```cpp
  static void copia(nodo* primo, nodo*& f, nodo*& l) {
    if(primo == nullptr) {
      f=l=nullptr;
      return;
    }
    copia(primo->next,f,l);
    f = new nodo(primo->info,nullptr,f);
    if(f->next == nullptr)
      l = f;
    else
      (f->next)->prev = f;
  }
  ```
  *B*: iterativa

  ```cpp
  static void copia(nodo* orig, nodo*& f, nodo*& l){
    f = l = nullptr;
    for(; orig; orig = orig->next){
        nodo* n = new nodo(orig->info, nullptr, l);
        if(l) l->next = n;
        else  f = n;
        l = n;
    }
  }
  ```
]

#slide()[
  *Ricorsiva*: scende fino in fondo, poi costruisce *risalendo*

  #text(size: 0.9em)[`copia(1,2,3)` #sym.arrow `copia(2,3)` #sym.arrow `copia(3)` #sym.arrow `copia(vuota)`]

  #v(0.4em)
  Cosa restituisce ogni chiamata, dal basso verso l'alto:

  #grid(
    columns: (auto, 1fr),
    row-gutter: 0.8em,
    column-gutter: 0.8em,
    [`copia(vuota)`], [#vuota],
    [`copia(3)`], [#nodo(3, new: true)],
    [`copia(2,3)`], [#nodo(2, new: true)#ar#nodo(3)],
    [`copia(1,2,3)`], [#nodo(1, new: true)#ar#nodo(2)#ar#nodo(3)],
  )

  I nodi nascono dall'*ultimo al primo*: "copia il resto, poi aggiungi me davanti".
]

#slide()[
  *Iterativa*: scorre l'originale e aggiunge *in coda*

  #text(size: 0.9em)[`orig` legge: 1 #sym.arrow 2 #sym.arrow 3]

  #v(0.4em)
  La nuova lista dopo ogni giro del ciclo:

  #grid(
    columns: (auto, 1fr),
    row-gutter: 0.8em,
    column-gutter: 0.8em,
    [`inizio`], [#vuota #text(size: 0.8em)[ (`f = l = nullptr`)]],
    [`giro 1`], [#nodo(1, new: true) #text(size: 0.8em)[ (`f = l = 1`)]],
    [`giro 2`], [#nodo(1)#ar#nodo(2, new: true) #text(size: 0.8em)[ (`l = 2`)]],
    [`giro 3`], [#nodo(1)#ar#nodo(2)#ar#nodo(3, new: true) #text(size: 0.8em)[ (`l = 3`)]],
  )

  I nodi nascono dal *primo all'ultimo*: "per ogni nodo, aggiungimi in coda".
]

#slide(title: "Idea 4: il confronto lessicografico")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *A*: `<`, `<` invertito, poi `==`

      ```cpp
      if(f1->info < f2->info) return true;
      if(f2->info < f1->info) return false;
      if(f1->info == f2->info)
        return rec_lex_ord(f1->next,
                           f2->next);
      return false;
      ```
    ],
    [
      *B*: solo `<`

      ```cpp
      while(a && b) {
        if(a->info < b->info) return true;
        if(b->info < a->info) return false;
        a = a->next; b = b->next;
      }
      return !a && b;
      ```
    ],
  )
]

#slide(title: "Idea 4 bis: requisiti su T")[
  *A*: un solo costruttore con valori di default

  ```cpp
  dList(unsigned int k = 0, const T& t = T());
  nodo(const T& t = T(), nodo* p = 0, nodo* n = 0);
  ```

  - comodo: copre costruttore a 0, 1 e 2 parametri
  - ma `T` deve avere il *costruttore di default*, anche se `k` è dato

  *B*: costruttore di default e `dList(k, t)` separati, `nodo` senza default per `T`

  - funziona anche con tipi senza costruttore di default
]

#slide(title: "Idea 5: operator=")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *A*: copia, poi distrugge

      ```cpp
      if(this != &d) {
        nodo *f, *l;
        copia(d.first, f, l);
        distruggi(first);
        first = f; last = l;
      }
      ```
    ],
    [
      *B*: distrugge, poi copia

      ```cpp
      if(this != &d) {
        distruggi(first);
        copia(d.first, first, last);
      }
      ```
    ],
  )

  - se `new` fallisce durante la copia, in A l'oggetto di partenza resta *intatto*
  - in B la vecchia lista è già persa
  - qui *A è la scelta migliore*
]

#slide(title: "Dove A è meglio, dove B")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *A*

      - `operator=` robusto
      - codice più breve, vicino alla definizione ricorsiva
      - segnala esplicitamente `*end()`
    ],
    [
      *B*

      - niente `last+1`: `iter` punta sempre a un nodo
      - cicli: nessun rischio di stack
      - meno requisiti su `T` (`==`, costruttore di default)
    ],
  )
]

#slide(title: "Cosa portare via")[
  - un iteratore past-the-end si può rappresentare in più modi: conta *dichiarare l'invariante* (cosa significa `ptr`, cosa significa `pte`)
  - definire i *casi limite* (`--begin()`, `*end()`, lista vuota) prima di scrivere il codice
  - la ricorsione è elegante, ma ha un costo in stack
  - chiedere a `T` il *minimo* indispensabile
  - in `operator=`: *prima si copia, poi si distrugge*
]

#slide(title: "Il nuovo main")[
  ```
  struct Punto { int x, y; };   // da mettere prima del main

  int main(){
    dList<int>::const_iterator it = x.begin();
    std::cout << "primo di x: " << *it << std::endl;
    ++it;
    std::cout << "secondo di x + 1: " << *it + 1 << std::endl;

    const int& r = *it;                       // riferimento all'elemento, nessuna copia
    std::cout << "r = " << r << std::endl;

    int somma = 0;
    for(dList<int>::const_iterator cit = y.begin(); cit != y.end(); ++cit)
      somma += *cit;
    std::cout << "somma di y = " << somma << std::endl;

    dList<int>::const_iterator ult = y.end();
    --ult;                                    // da end() si torna sull'ultimo elemento
    std::cout << "ultimo di y: " << *ult << std::endl;

    // *it = 5;                               // ERRORE: const_iterator, l'elemento è const
  ```
]

#slide()[
  ```
  // ---------- uso di -> (accesso a un membro dell'elemento) ----------
    dList<std::string> s;
    s.insertBack("campana"); s.insertBack("cavolo"); s.insertBack("ok");
    for(dList<std::string>::const_iterator cit = s.begin(); cit != s.end(); ++cit)
      std::cout << *cit << " ha " << cit->size() << " lettere" << std::endl;

    Punto a = {1, 2}, b = {3, 4};
    dList<Punto> p;
    p.insertBack(a); p.insertBack(b);
    for(dList<Punto>::const_iterator cit = p.begin(); cit != p.end(); ++cit)
      std::cout << "(" << cit->x << ", " << cit->y << ") ";
    std::cout << std::endl;

    dList<Punto>::const_iterator pit = p.begin();
    std::cout << pit->x << " " << (*pit).x << std::endl;   // sono la stessa cosa

    // pit->x = 9;                            // ERRORE: const_iterator
    // x.begin()->size();                     // ERRORE: int non ha membri, qui serve *
  }
  ```

  *ATTENZIONE, È NEL CODICE DEL PROF*

]