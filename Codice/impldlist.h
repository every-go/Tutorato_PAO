#ifndef IMPLDLIST_H
#define IMPLDLIST_H

#include <iostream>
#include "dlist.h"

/* ===================== nodo ===================== */

template<class T>
dList<T>::nodo::nodo(const T& t, nodo* n, nodo* p)
   : next(n), prec(p), info(t) {}

/* ================ metodi statici ================ */

// Dealloca tutti i nodi a partire da p (iterativo: niente rischio di stack overflow)
template<class T>
void dList<T>::distruggi(nodo* p){
   while(p){
      nodo* succ = p->next;
      delete p;
      p = succ;
   }
}

// Copia profonda della lista che inizia in orig. Alla fine f e l puntano
// al primo e all'ultimo nodo della nuova lista (nullptr se orig e' vuota)
template<class T>
void dList<T>::copia(nodo* orig, nodo*& f, nodo*& l){
   f = l = nullptr;
   for(; orig; orig = orig->next){
      nodo* n = new nodo(orig->info, nullptr, l);
      if(l) l->next = n;
      else  f = n;
      l = n;
   }
}

// true se la lista che inizia in a e' lessicograficamente < di quella che inizia in b.
// Usa solo operator< su T.
template<class T>
bool dList<T>::min(nodo* a, nodo* b){
   while(a && b){
      if(a->info < b->info) return true;
      if(b->info < a->info) return false;
      a = a->next;
      b = b->next;
   }
   // almeno una delle due e' finita: a < b solo se a e' finita e b no (a e' prefisso proprio di b)
   return a == nullptr && b != nullptr;
}

/* ============ costruttori e big 3 ============ */

template<class T>
dList<T>::dList() : first(nullptr), last(nullptr) {}

template<class T>
dList<T>::dList(unsigned int k, const T& t) : first(nullptr), last(nullptr){
   for(unsigned int i = 0; i < k; ++i)
      insertBack(t);
}

template<class T>
dList<T>::~dList(){
   distruggi(first);
}

template<class T>
dList<T>::dList(const dList& d){
   copia(d.first, first, last);
}

template<class T>
dList<T>& dList<T>::operator=(const dList& d){
   if(this != &d){
      distruggi(first);
      copia(d.first, first, last);
   }
   return *this;
}

/* ================== inserimenti ================== */

template<class T>
void dList<T>::insertFront(const T& t){
   nodo* n = new nodo(t, first, nullptr);
   if(first) first->prec = n;
   else      last = n;       // lista era vuota
   first = n;
}

template<class T>
void dList<T>::insertBack(const T& t){
   nodo* n = new nodo(t, nullptr, last);
   if(last) last->next = n;
   else     first = n;       // lista era vuota
   last = n;
}

/* ================== confronti ================== */

template<class T>
bool dList<T>::operator<(const dList& d) const{
   return min(first, d.first);
}

template<class T>
bool dList<T>::operator<=(const dList& d) const{
   return !(d < *this);
}

/* ================== stampa ================== */

template<class T>
void dList<T>::printList() const{
   for(nodo* p = first; p; p = p->next)
      std::cout << p->info << " ";
   std::cout << std::endl;
}

template<class T>
void dList<T>::printList_backward() const{
   for(nodo* p = last; p; p = p->prec)
      std::cout << p->info << " ";
   std::cout << std::endl;
}

/* ================== const_iterator ================== */

template<class T>
dList<T>::const_iterator::const_iterator(const nodo* p, bool pte)
   : iter(p), past_the_end(pte) {}

template<class T>
bool dList<T>::const_iterator::operator==(const const_iterator& it) const{
   return iter == it.iter && past_the_end == it.past_the_end;
}

template<class T>
bool dList<T>::const_iterator::operator!=(const const_iterator& it) const{
   return !(*this == it);
}

// ++it : se siamo sull'ultimo nodo si passa allo stato "past-the-end"
template<class T>
typename dList<T>::const_iterator& dList<T>::const_iterator::operator++(){
   if(iter && !past_the_end){
      if(iter->next) iter = iter->next;
      else           past_the_end = true;   // iter resta sull'ultimo nodo
   }
   return *this;
}

template<class T>
typename dList<T>::const_iterator dList<T>::const_iterator::operator++(int){
   const_iterator aux = *this;
   ++(*this);
   return aux;
}

// --it : da past-the-end si torna sull'ultimo nodo
template<class T>
typename dList<T>::const_iterator& dList<T>::const_iterator::operator--(){
   if(iter){
      if(past_the_end)     past_the_end = false;
      else if(iter->prec)  iter = iter->prec;
   }
   return *this;
}

template<class T>
typename dList<T>::const_iterator dList<T>::const_iterator::operator--(int){
   const_iterator aux = *this;
   --(*this);
   return aux;
}

// true se l'iteratore punta ad un elemento dereferenziabile
template<class T>
bool dList<T>::const_iterator::is_valid() const{
   return iter != nullptr && !past_the_end;
}

template<class T>
const T* dList<T>::const_iterator::operator->() const{
   return &(iter->info);
}

template<class T>
const T& dList<T>::const_iterator::operator*() const{
   return iter->info;
}

/* ================== begin / end ================== */

// Lista vuota: begin() == end() (entrambi nullptr + past_the_end = true)
template<class T>
typename dList<T>::const_iterator dList<T>::begin() const{
   if(!first) return const_iterator();
   return const_iterator(first);
}

// past-the-end: punta all'ultimo nodo con il flag past_the_end = true,
// cosi' --end() ritorna sull'ultimo elemento
template<class T>
typename dList<T>::const_iterator dList<T>::end() const{
   if(!first) return const_iterator();
   return const_iterator(last,true);
}

#endif


/*
SENZA METODI STATICI, SI PUÒ FARE COSÌ

template<class T>
dList<T>::~dList(){
   while(first){
      nodo* succ = first->next;
      delete first;
      first = succ;
   }
}

template<class T>
dList<T>::dList(const dList& d) : first(nullptr), last(nullptr){
   for(nodo* p = d.first; p; p = p->next)
      insertBack(p->info);          // riusa insertBack, O(1) ciascuno
}

template<class T>
dList<T>& dList<T>::operator=(const dList& d){
   if(this != &d){
      // distruzione (stesso ciclo del distruttore)
      while(first){
         nodo* succ = first->next;
         delete first;
         first = succ;
      }
      last = nullptr;
      // copia
      for(nodo* p = d.first; p; p = p->next)
         insertBack(p->info);
   }
   return *this;
}

template<class T>
bool dList<T>::operator<(const dList& d) const{
   nodo* a = first;
   nodo* b = d.first;
   while(a && b){
      if(a->info < b->info) return true;
      if(b->info < a->info) return false;
      a = a->next;
      b = b->next;
   }
   return a == nullptr && b != nullptr;
}

*/