import moment from 'moment'
import axios from 'axios'

const defaults = {
  format: {
    decs: 2,
    numSep: ' ',
    date: 'DD MMM YYYY',
    datetime: 'DD MMM YYYY hh:mm:ss a',
    time: 'hh:mm:ss a'
  }
}

const md = new Markdown('commonmark', {html: false})
const formatMethods = {
  md(txt) {
    if (txt) {
      return md.render(txt)
    } else {
      return ''
    }
  },
  getUser (id, field = 'full_name') {
    if(!field) {
      return users[id]
    } else {
      return users[id][field]
    }
  },
  dateFormat (date, format = defaults.format.date, utc = true) {
    if (utc) {
      return moment.utc(date).local().format(format)
    } else {
      return moment(date).format(format)
    }
  },
  datetimeFormat (date, format = defaults.format.datetime, utc = true) {
    if(utc) {
      return moment.utc(date).local().format(format)
    } else {
      return moment(date).format(format)
    }
  },
  timeFormat (date, format = defaults.format.time,utc = true) {
    if (utc) {
      return moment.utc(date).local().format(format)
    } else {
      return moment(date).format(format)
    }
  },
  timeAgo (t) {
    return moment.utc(t).fromNow()
  },
  getUrl (pre, id) {
    return [pre, id].join('/')
  },
  toFixed (val, decs = defaults.format.decs) {
    if(typeof(val) === 'string') {
      val = parseFloat(val)
    }
    return (Math.round(val * Math.pow(10, decs)) / Math.pow(10, decs)).toFixed(decs)
  },
  formatNumber (val, decs = defaults.format.decs, sep = defaults.format.numSep) {
    let sepa = `$1${sep}`
    return this.toFixed(val, decs).replace(/(\d)(?=(\d{3})+\.)/g, sepa)
  },
  readError (obj, field) {
    if(obj && obj.errors && obj.errors[field]) {
      return obj.errors[field]
    } else {
      return ''
    }
  },
  hasError (obj, field) {
    if(obj && obj.errors && obj.errors[field]) {
      return 'has-error is-invalid'
    } else {
      return ''
    }
  },
  escapeHTML (unsafe) {
    return unsafe.replace(/[&<"']/g, function(m) {
      switch (m) {
        case '&':
          return '&amp;'
        case '<':
          return '&lt;'
        case '"':
          return '&quot;'
        default:
          return '&#039;'
      }
    })
  },
  currency (cur) {
    switch (cur) {
      case 'BOB':
        return 'Bs.'
      case 'USD':
        return '$'
      case 'EUR':
        return 'E'
      default:
        return 'Bs.'
    }
  },
  formatNum (num) {
    let str = String(num)
    switch (str.length) {
      case 1:
        return '00' + num
      case 2:
        return '0' + num
      default:
        return num
    }
  }
}

export const global = {
  computed: {
    xhr () {
      return axios.create({
        headers: {
          'x-csrf-token': document.querySelector('[name=csrf]').content
        }
      })
    }
  },
  filters: {
    number (val, decs, sep) {
      return formatMethods.formatNumber(val, decs, sep)
    },
    price (val) {
      return formatMethods.formatNumber(val, 2)
    },
    phone (num) {
      return `+${num.slice(0, 3)} ${num.slice(3, 12)}`
    },
    date (date, format = defaults.format.dateFormat) {
      return formatMethods.dateFormat(date, format)
    },
    datetime (date, format = defaults.format.datetimeFormat) {
      return formatMethods.datetimeFormat(date, format)
    },
    time (date, format = defaults.format.timeFormat) {
      return formatMethods.timeFormat(date, format)
    },
    num (num) {
      return formatMethods.formatNum(num)
    },
    currency (val) {
      switch (val) {
        case 'BOB':
          return 'Bs'
        case 'USD':
          return '$'
        default:
          return val
      }
    }
  },
  methods: formatMethods
}
