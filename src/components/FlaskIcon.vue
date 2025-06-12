<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 100 100"
    xmlns="http://www.w3.org/2000/svg"
    class="flask-icon"
  >
    <!-- Flask Body -->
    <defs>
      <linearGradient id="flaskGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#00bcd4;stop-opacity:1" />
        <stop offset="50%" style="stop-color:#2196f3;stop-opacity:1" />
        <stop offset="100%" style="stop-color:#9c27b0;stop-opacity:1" />
      </linearGradient>
      <linearGradient id="liquidGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style="stop-color:#00e5ff;stop-opacity:0.9" />
        <stop offset="50%" style="stop-color:#2196f3;stop-opacity:0.8" />
        <stop offset="100%" style="stop-color:#673ab7;stop-opacity:0.9" />
      </linearGradient>
    </defs>
    
    <!-- Flask outline -->
    <path
      d="M35 25 L35 40 L20 70 Q20 80 30 80 L70 80 Q80 80 80 70 L65 40 L65 25"
      fill="none"
      stroke="url(#flaskGradient)"
      stroke-width="3"
      stroke-linecap="round"
      stroke-linejoin="round"
    />
    
    <!-- Flask neck -->
    <path
      d="M40 15 L40 25 L60 25 L60 15"
      fill="none"
      stroke="url(#flaskGradient)"
      stroke-width="3"
      stroke-linecap="round"
    />
    
    <!-- Flask top -->
    <path
      d="M38 15 L62 15"
      stroke="url(#flaskGradient)"
      stroke-width="3"
      stroke-linecap="round"
    />
    
    <!-- Liquid inside -->
    <path
      d="M35 40 L25 65 Q25 75 32 75 L68 75 Q75 75 75 65 L65 40 C65 45 60 50 50 55 C40 50 35 45 35 40"
      fill="url(#liquidGradient)"
      opacity="0.8"
    />
    
    <!-- Bubbles -->
    <circle cx="45" cy="60" r="2" fill="#00e5ff" opacity="0.7">
      <animate attributeName="r" values="2;3;2" dur="2s" repeatCount="indefinite" />
      <animate attributeName="opacity" values="0.7;1;0.7" dur="2s" repeatCount="indefinite" />
    </circle>
    <circle cx="55" cy="50" r="1.5" fill="#64b5f6" opacity="0.6">
      <animate attributeName="r" values="1.5;2.5;1.5" dur="1.5s" repeatCount="indefinite" />
      <animate attributeName="opacity" values="0.6;1;0.6" dur="1.5s" repeatCount="indefinite" />
    </circle>
    <circle cx="40" cy="45" r="1" fill="#00e5ff" opacity="0.8">
      <animate attributeName="r" values="1;2;1" dur="1.8s" repeatCount="indefinite" />
      <animate attributeName="opacity" values="0.8;1;0.8" dur="1.8s" repeatCount="indefinite" />
    </circle>
    
    <!-- Floating bubbles outside flask -->
    <circle cx="30" cy="20" r="3" fill="#00e5ff" opacity="0.6">
      <animate attributeName="cy" values="20;15;20" dur="3s" repeatCount="indefinite" />
      <animate attributeName="opacity" values="0.6;1;0.6" dur="3s" repeatCount="indefinite" />
    </circle>
    <circle cx="75" cy="25" r="2" fill="#9c27b0" opacity="0.5">
      <animate attributeName="cy" values="25;20;25" dur="2.5s" repeatCount="indefinite" />
      <animate attributeName="opacity" values="0.5;0.9;0.5" dur="2.5s" repeatCount="indefinite" />
    </circle>
  </svg>
</template>

<script setup>
defineProps({
  size: {
    type: [String, Number],
    default: 40
  }
})
</script>

<style scoped>
.flask-icon {
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
}
</style> 