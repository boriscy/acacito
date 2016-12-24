import axios from 'axios'


export default axios.create({
  timeout: 1000,
  headers: {'Authorization': localStorage.getItem('authToken')}
});
