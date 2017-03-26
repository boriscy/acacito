import {xhr} from './xhr'

export default {
  openCloseOrganization(cb) {
    xhr.put('/organizations/open_close')
    .then((res) => {
      cb(res.data)
    })
    .catch(error => {
      cb(error.response)
    })
  }
}

