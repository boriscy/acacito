import moment from 'moment'


export const translate = {
  methods: {
    gettext: function(trans) {
      return window.translations[trans] || trans
    }
  }
}

export const format = {
  methods: {
    user: function(id, field = 'full_name') {
      if(!field) {
        return users[id]
      } else {
        return users[id][field]
      }
    },
    dateFormat: function(date, format = defaults.format.dateFormat) {
      return moment(date).format(format)
    },
    datetimeFormat: function(date, format = defaults.format.datetimeFormat) {
      return moment(date).format(format)
    },
    getUrl: function(pre, id) {
      return [pre, id].join('/')
    },
    toFixed: function(val, decs = defaults.format.decs) {
      if(typeof(val) === 'string') {
        val = parseFloat(val)
      }
      return (Math.round(val * Math.pow(10, decs)) / Math.pow(10, decs)).toFixed(decs)
    },
    numberFormat: function(val, decs = defaults.format.decs, sep = defaults.format.numSep) {
      let sepa = `$1${sep}`
      return this.toFixed(val, decs).replace(/(\d)(?=(\d{3})+\.)/g, sepa)
    },
    readError: function(obj, field) {
      if(obj && obj.errors && obj.errors[field]) {
        return obj.errors[field]
      } else {
        return ''
      }
    },
    hasError: function(obj, field) {
      if(obj && obj.errors && obj.errors[field]) {
        return 'has-error'
      } else {
        return ''
      }
    }
  }
}
