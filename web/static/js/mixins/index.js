import moment from 'moment'


export const translate = {
  methods: {
    gettext: function(trans) {
      if(!window.translations[trans]) {
        console.warn(`No translation for: ${trans}`)
      }
      return window.translations[trans] || trans
    }
  }
}

const defaults = {
  format: {
    decs: 2,
    numSep: " "
  }
}

export const format = {
  methods: {
    getUser(id, field = 'full_name') {
      if(!field) {
        return users[id]
      } else {
        return users[id][field]
      }
    },
    dateFormat(date, format = defaults.format.dateFormat) {
      return moment(date).format(format)
    },
    datetimeFormat(date, format = defaults.format.datetimeFormat) {
      return moment(date).format(format)
    },
    getUrl(pre, id) {
      return [pre, id].join('/')
    },
    toFixed(val, decs = defaults.format.decs) {
      if(typeof(val) === 'string') {
        val = parseFloat(val)
      }
      return (Math.round(val * Math.pow(10, decs)) / Math.pow(10, decs)).toFixed(decs)
    },
    formatNumber(val, decs = defaults.format.decs, sep = defaults.format.numSep) {
      let sepa = `$1${sep}`
      return this.toFixed(val, decs).replace(/(\d)(?=(\d{3})+\.)/g, sepa)
    },
    readError(obj, field) {
      if(obj && obj.errors && obj.errors[field]) {
        return obj.errors[field]
      } else {
        return ''
      }
    },
    hasError(obj, field) {
      if(obj && obj.errors && obj.errors[field]) {
        return 'has-error'
      } else {
        return ''
      }
    },
    escapeHTML(unsafe) {
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
    currency(cur) {
      switch(cur) {
        case 'BOB':
          return 'Bs.'
        case 'USD':
          return '$'
        case 'EUR':
          return 'E'
        default:
          return 'Bs.'
      }
    }
  }
}
