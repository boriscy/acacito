import OrderList from './orders/List.vue'
//import Show from './components/ledgers/Show.vue'
//import New from './components/ledgers/New.vue'


export default [
  {
    path: '/orders', component: OrderList
    //children: [
    //  { path: 'new', component: New },
    //  { path: ':id', component: Show }
    //]
  }
]
