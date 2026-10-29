#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#show raw.where(block: true, lang: none): it => raw(it.text, lang: "cpp", block: true)
#show raw.where(lang: "cpp"): set text(size: 0.7em)
#let size(s, body) = {
  show raw: set text(size: s)
  body
}

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 3",
  date: "03 Novembre 2026",
)

#filled-slide()[
  Template
]

#slide(title: "Template")[
  I template possono essere
  + Template di funzione
  + Template di classe

  Assieme definiscono l'idea del cosiddetto _polimorfismo parametrico_.
]


#slide(title: "Template di funzione")[
  Sono descrizioni di un metodo che il compilatore può usare per generare automaticamente (in maniera implicita oppure esplicita) istanze particolari di una funzione che differiscono per il tipo degli argomenti.
  #grid(
    columns: (50%, 50%),
    [
      ```cp
      template <class T>
      T min(T a, T b) {
        return a < b ? a : b;
      }
      ```
    ],
    [
      ```cp
      template <class T, int size>
      bool min(T a) {
        return a < size;
      }
      ```
      Qui si presuppone che T possa essere confrontabile con _int_.
    ]
  )
  
  I parametri possono essere:
  + Parametri di tipo (preceduti da _class_ o _typename_, possono essere di qualsiasi tipo)
  + Parametri valore (tipo predefinito)
]

#slide(title: "Istanziazione")[
  L'istanziazione può essere:
  + Implicita
  + Esplicita
]

#slide(title: "Istanziazione implicita")[
  Il tipo degli elementi viene dedotto da sinistra a destra, e nel caso in cui ci siano più parametri di tipo T questi devono essere *esattamente* uguali fra di loro.\
  Con l'esempio _min_ precedente
  ```cpp
  int i; double d;
  min(i, d); //ERRORE di compilazione perché sono due tipi diversi
  ```
  Questo obbliga il programmatore a scegliere con cautela le istanziazioni implicite in quanto il compilatore non può sapere quale tipo veramente il programmatore voleva usare.\
  Tuttavia sono ammesse conversioni:
  + T& $->$ T
  + T[] $->$ T\*
  + T $->$ const T
  + T $->$ const T&
]

#slide(title: "Istanziazione esplicita")[
  Riutilizzando l'esempio precedente, per fare compilare l'uso di due diversi tipi, si può fare così:
  ```cp
  int i; double d;
  min<double>(i, d); //compila, i diventa un double con la conversione int -> double
  ```
  Solitamente si usa per risolvere ambiguità.
]

#slide(title: "Uso di array statici")[
  Quando si vuole usare un array statico, la dimensione costante dell'array è parte integrante del tipo del parametro, e per questo molto limitante all'uso di *qualsiasi* array statico.\
  Per questo, quando si costruisce un template di funzione, si usa il parametro per *valore* _int size_.
  ```cp
  template<class T, int size>
  T min(T (&a)[size]) {
    ......
  }

  int main(){
    int ia[20];
    cout << min(ia);
    cout << min<int,20>(ia);
  }
  ```
]

#filled-slide[
  Compilazione
]

#slide(title: "Compilazione dei template")[
  La definizione del solo template non porta ad alcun oggetto compilabile.\
  Oltretutto, è impossibile "emulare" l'information hiding con i template, in quanto non essendo oggetti compilabili direttamente si è costretti a consegnare il template nei file header.\
  Tuttavia, c'è un modo per limitare la compilazione di (potenzialmente) infiniti template.
]

#slide(title: "Compilazione per inclusione")[
  #text(size: 20pt)[
    Viene usato sia per i template di funzione che per i template di classe.\
    Le definizioni dei template vengono messe nei file header, i quali devono essere inclusi in ogni file che usa il template.\
    Tuttavia rimane il problema per cui se la stessa istanza di un template viene usata in più file compilati separamente il codice per tale istanza viene generato più volte dal compilatore.\
    Si può forzare il compilatore a generare le istanze del template che vengono usate nel programma con delle _dichiarazioni esplicite di istanziazione_.
  ]
  ```cpp
  template <class T>
  T min(T a, T b) { return a < b ? a : b; }

  template int min(int, int);
  ```
  #text(size: 20pt)[
  La flag *-fno-implicit-templates* comunica che una dichiarazione esplicita di istanziazione compare in un altro file e che il template di funzione non deve essere istanziato.
  ]
]

#filled-slide()[
  Template di classe
]

#slide(title: "Come funziona")[
  È la descrizione di un metodo che il compilatore può usare per generare automaticamente istanze particolari di una classe che differiscono per il tipo di alcuni membri, l'istanziazione è sempre *esplicita*
  ```
  template<class T>
  class Queue{
    public:
      Queue();
      ~Queue();
      bool is_empty() const;
      void add(const T&);
      T remove();
  };
  ```
  Per definire una classe Queue (coda)
  ```cpp
  Queue<int> qi;
  ```
  I parametri, sia di tipo che di valore, possono avere parametri di default.
]

#slide(title: "Queue e QueueItem")[
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      template <class T>
      class QueueItem;

      template <class T>
      class Queue{
        public:
          Queue();
          ~Queue();
          bool is_empty() const;
          void add(const T&);
          T remove();
        private:
          QueueItem<T>* primo;
          QueueItem<T>* ultimo;
      };
      ```
    ],
    [
      ```cpp
      template <class T>
      class QueueItem{
        public:
          QueueItem(const T&);
          T info;
          QueueItem* next;
      };
      ```
    ]
  )
]

#slide(title: "Istanziazioni di un template di classe")[
  Nel caso in cui vengano generate più classi, ad esempio
  - Queue\<int>
  - Queue\<string>
  Sono due classi completamente distinte che non possono accedere fra di loro alla parte privata della classe.
  ```cpp
  template<class T>
  int f(Queue<T>& qT, Queue<string> qS);
  ```
  È completamente legale.\
  Anche in questo caso, per definire template di classe o funzione si può sfruttare una dichiarazione incompleta della classe.
]

#slide(title: "Definizione esterna")[
  ```cpp

  template<class T>
  class Queue{
    public:
      Queue();
    private:
      QueueItem<T>* primo;
      QueueItem<T>* ultimo;
  };

  //definizione esterna
  template <class T>
  Queue<T>::Queue() : primo(0), ultimo (0) {}
  ```

  Il metodo di un template di classe non viene istanziato quando viene istanziata la classe ma se e soltanto quando il programma usa effettivamente quel metodo.
]

#filled-slide()[
  Dichiarazioni friend
]

#slide(title: "Possibili dichiarazioni")[
  + Dichiarazione nel template di classe C di una classe o funzione friend non template
  + Dichiarazione nel template di classe C di  un template di classe o di un template di funzione friend associato, cioè avente tra i suoi parametri alcuni dei parametri di template C
  + Dichiarazione nel template di classe C di un template di classe o di un template di funzione friend non associato, cioè avente i parametri disgiunti dai parametri di C
]

#slide(title: "Esempio 1")[
  ```cpp
  class A {
    ...
    int fun();
    ...
  };

  template<class T>
  class C{
    friend int A::fun();
    friend class B;
    friend bool test();
  };
  ```
  La classe B, la funzione test() e il metodo A::fun() sono friend di *tutte le istanze* del template di classe C.
]

#slide(title: "Esempio 2")[
  ```
  template <class T> class A{... int fun(); ...};
  template <class T> class B { ... };

  template<class T1, class T2> class C;

  template<class T1, class T2> bool test(C<T1,T2>);

  template<class T1, class T2> class C{
    friend int A<T1>::fun();
    friend class B<T2>;
    friend bool test<T1,T2>(C);
  };
  ```
  Ad ogni istanza del template di classe C rimane associata come amica *una ed una sola* istanza del template di classe B e dei template di funzione A\<T>::fun() e test.\
  Le dichiarazioni dei template di classe A e B e del template di funzione test devono essere visibili quando viene definito il template di classe C.\
  Per dichiarare test è necessaria la dichiarazione (anche incompleta) di C.
]

#slide(title: "Esempio 3")[
  ```cpp
  template <class T>
  class C{
    T t;
    template<class Tp>
    friend int A<Tp>::fun();

    template <class Tp>
    friend class B;

    template<class Tp>
    friend bool test(C<Tp>);
  };
  ```
  I template di classe o di funzione dichiarati friend sono friend di ogni istanza del template di classe C.
]

#slide(title: "Membri statici")[
  Se un template di classe contiene un membro statico, ne viene creato uno nuovo per ogni nuova istanza della classe.
  ```cpp
  template<int I>
  class C{
    static int numero;
    public:
      C();
  };

  template<int I>
  int C<I>::numero = I;

  template<int I>
  C<I>::C() { numero ++; }

  int main(){
    C<1> uno; C<2> due_a; C<2> due_b;
  }
  ```
]

#filled-slide()[
  Typename
]

#slide(title: "Typename")[
  La parola chiave _typename_ ha due usi:
  + Come *alternativa a _class_* nella lista dei parametri di tipo
  + Per indicare che un *nome dipendente* è un tipo

  ```cpp
  template <class T>
  T min(T a, T b);

  template <typename T>
  T min(T a, T b);
  ```
]

#slide(title: "Nomi dipendenti")[
  Dentro un template, un nome qualificato che dipende da un parametro (come `T::x`) non è risolvibile finché T non è noto.\
  Per default il compilatore assume che sia un *valore* (es. un membro statico), non un tipo.
  ```cpp
  template <class T>
  void f() {
    T::x * p;
    // dichiarazione di un puntatore p a T::x
    // oppure moltiplicazione tra T::x e p?
  }
  ```
  Il compilatore sceglie la moltiplicazione. Per dire che `T::x` è un tipo si scrive
  ```cpp
  typename T::x * p;
  ```
]

#slide(title: "Quando è obbligatorio")[
  È necessario davanti a un nome *qualificato* e *dipendente* da un parametro di template che denota un tipo.
  ```cpp
  template <class T>
  void stampa(const T& c) {
    typename T::const_iterator it = c.begin();
    for (; it != c.end(); ++it)
      cout << *it << endl;
  }
  ```
  Non si usa:
  - Per nomi non dipendenti (es. `std::string`)
  - Nella lista delle classi base e negli inizializzatori del costruttore
]

#filled-slide()[
  Contenitori STL
]

#slide(title: "Standard Template Library")[
  È una libreria di contenitori.\
  Ogni funzione indica la complessità massima con la quale deve essere presente.\
  STL ha contenitori, iteratori, algoritmi.\
  Chiaramente sono ridefiniti tutti gli operatori importanti (la regola del 3) e gli operatori di confronto (<, $<=$ ecc).
]

#slide(title: "Vector")[
  Restituisce array dinamico con capacity()$>=$size().\
  È il più semplice contenitore e per la maggioranza delle applicazioni è il più efficiente.
  + Supporto accesso casuale O(1)
  + Inserimento e rimozione in coda a tempo costante ammortizzato
  + Inserimento e rimozione in coda a tempo lineare ammortizzato
  + La capacità può variare dinamicamente (potenza di 2)
  + La gestione della memoria è automaticamente
  La capacità raddoppia ogni volta che c'è bisogno di una cella oltre capacity().
]

#slide(title: "Template vector")[
  Template a 2 parametri:
  ```cpp
  template <class T, class Alloc = allocator<T>> class vector;
  ```
  Il primo è il tipo degli elementi, il secondo l'allocatore (quasi sempre quello di default).\
  Size iniziale e valore di default si passano al *costruttore*:
  ```cpp
  vector<int> v;         // vuoto
  vector<int> v(10);     // 10 elementi, tutti 0
  vector<int> v(10, 7);  // 10 elementi, tutti 7
  ```
]

#slide(title: "Metodi fondamentali")[
  ```cpp
  void push_back(const T&); //aggiungi in coda
  void pop_back(); //rimuovi in coda
  T& front();
  T& back();
  iterator begin();
  iterator end();
  bool empty(); //comune a tutti i contenitori
  int size(); //comune a tutti i contenitori
  ```
  Ad ogni classe contenitore si ha
  - C::iterator
  - C::const\_iterator
]

#slide(title: "Iteratori")[
  Un iteratore si comporta come un puntatore: `*it` accede all'elemento, `++it` passa al successivo.
  ```cpp
  vector<int> v;
  v.push_back(1); v.push_back(2);

  for (vector<int>::iterator it = v.begin(); it != v.end(); ++it)
    cout << *it << endl;
  ```
  Dentro un template serve `typename`:
  ```cpp
  template <class T>
  void stampa(const vector<T>& v) {
    typename vector<T>::const_iterator it = v.begin();
    ...
  }
  ```
]

#slide(title: "Altri contenitori")[
  Esistono altri contenitori come:
  - list (lista doppiamente linkata)
  - deque (coda con accessi sia dal "fronte" che dal "retro")
  -
]