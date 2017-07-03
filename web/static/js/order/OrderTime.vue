<script>
import {format} from '../mixins'
import Modal from '../globals/Modal.vue'


export default {
  name: 'OrderTime',
  mixins: [format],
  components: {
    Modal
  },
  watch: {
    //'form.hour': function (a) { console.log('watch', a) },
    'form.time_num': function (a) { console.log('watch tn', a) }
  },
  computed: {
    hours() {
      let h = []
      for(let i = 0; i < 24; i++) {
        if(i < 10) {
          h.push(`0${i}`)
        } else {
          h.push(`${i}`)
        }
      }

      return h
    },
    minutes() {
      let m = []
      for(let i = 0; i < 12; i++) {
        if(i < 2) {
          m.push(`0${i * 5}`)
        } else {
          m.push(`${i * 5}`)
        }
      }

      return m
    },
    fullDate() {
      return this.dateTime()
    }
  },
  props: {
    order: {
      type: Object
    }
  },
  methods: {
    open() {
      this.setTime()
      this.$refs.modal.open()
    },
    getTime() {
      if('num' == time_type) {
        let d = new Date()
        return new Date(d.getTime() + +this.form.time_num * 1000 * 60).toJSON()
      } else {
        return this.dateTime()
      }
    },
    dateTime() {
      let d = new Date()
      //console.log(this.form.hour, this.form.minutes)
      let d2 = new Date(new Date(d.getFullYear(), d.getMonth(), d.getDate(), +this.form.hour, +this.form.minutes))
      //console.log(d, d2)

      if(d.getTime() > d2.getTime()) {
        return new Date(new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1, +this.form.hour, +this.form.minutes))
      } else {
        return d2
      }
    },
    setTime() {
      let d = new Date()
      let min = d.getMinutes() % 5
      d = new Date(d.getTime() + (3600 * 1000 - 1000 * 60 * min))

      if(d.getHours() < 10) {
        this.form.hour = `0${d.getHours()}`
      } else {
        this.form.hour = `${d.getHours()}`
      }

      if(d.getMinutes() < 10) {
        this.form.minutes = `0${d.getMinutes()}`
      } else {
        this.form.minutes = `${d.getMinutes()}`
      }
    }
  },
  data() {
    return {
      time_type: 'num', form: {time_num: 5, hour: null, minutes: null }
    }
  }
}
</script>
<template>
  <Modal headerCSS="blue" ref="modal">
    <div slot="title">
      <strong>{{order.num | num}}</strong>
      {{'Estimated time for preparation?' | translate}}
    </div>

    <div slot="body">
      <div class="form-group form-inline">
        <div>
          <label>
            <input type="radio" v-model="time_type" value="num" />
            {{'Minutes for preparation?' | translate}}
          </label>
        </div>

        <div v-show="'num'==time_type">
          <select v-model="form.time_num" class="form-control">
            <option v-for="v in 18" :value="v*5">{{v * 5}} {{'minutes' | translate}}</option>
          </select>
        </div>

        <div>
          <label>
            <input type="radio" v-model="time_type" value="time" />
            {{'Time for preparation?' | translate}}
          </label>
        </div>

        <div v-show="'time'==time_type">
          <select v-model="form.hour" class="form-control">
            <option v-for="h in hours" :value="h">{{h}}</option>
          </select>
          <select v-model="form.minutes" class="form-control">
            <option v-for="m in minutes" :value="m">{{m}}</option>
          </select>
        </div>

        {{dateTime() | datetime}}

      </div>
    </div>

    <div slot="footer">
      <button class="btn btn-default" @click="$refs.modal.close()">{{'Cancel' | translate}}</button>
      <button class="btn btn-success" @click="$parent.moveNextConfirm()">{{'Confirm time' | translate}}</button>
    </div>
  </Modal>
</template>
