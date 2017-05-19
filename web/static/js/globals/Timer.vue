<template>
  <span>{{minutes}}:{{seconds}}</span>
</template>

<script>
export default {
  computed: {
    minutes() { return Math.floor(this.count / 60) },
    seconds() {
      let v = this.count % 60
      if(v < 10) {
        return `0${v}`
      } else {
        return v
      }
    },
  },
  props: {
    interval: {
      type: Number,
      default: 1000
    }
  },
  data() {
    return {count: 0}
  },
  methods: {
    start() {
      this.inter = setInterval(() => {
        this.count ++
      }, this.interval)
    },
    stop() {
      clearInterval(this.inter)
    },
    reset() {
      clearInterval(this.inter)
      this.count = 0
    },
    restart() {
      this.reset()
      this.start()
    }
  },
  created() {
  }
}
</script>
