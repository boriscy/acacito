import axios from 'axios'

export const auth = axios.create({
  timeout: 5000,
  headers: {
    'Authorization': localStorage.getItem('authToken'),
    'orgtoken': localStorage.getItem('orgToken')
  }
});

export const xhr = axios.create({
  headers: {
    'x-csrf-token': document.querySelector('[name=csrf]').content
  }
})
