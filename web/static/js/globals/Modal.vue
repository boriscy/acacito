<template>
  <div>
    <div class="modal fade" tabindex="-1" role="dialog" @click="close($event)" :class="cssClass" :style="{display: display}">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close" @click="close()"><span aria-hidden="true">&times;</span></button>
            <slot name="title"></slot>
          </div>
          <div class="modal-body">
            <slot name="body">
            </slot>
          </div>
          <div class="modal-footer">
            <slot name="footer">
            </slot>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-backdrop fade in" :style="{display: display}"></div>
  </div>
</template>

<script>
export default {
  props: {
    closeCallback: Function
  },
  data() {
    return {
      display: 'none',
      cssClass: ''
    }
  },
  methods: {
    close: function(event) {
      if((event && event.target.className == 'modal fade in') || !event) {
        this.cssClass = ''
        this.display = 'none'
        this.$emit('close')
      }
    },
    open: function() {
      setTimeout(()=> {
        this.cssClass = 'in'
      },100)
      this.display = 'block'
    }
  }
}
</script>
