<template>
  <div class="bg-white rounded-lg p-4 border shadow-sm" data-chart>
    <div class="mb-4 flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-800">Distribution of Entered Proportions</h3>
      <div class="flex items-center space-x-3">
        <div class="text-sm text-gray-600">
          {{ data.length }} values entered
        </div>
        <!-- Normality Indicator -->
        <div v-if="data.length >= 5" class="flex items-center space-x-2">
          <div class="text-xs font-medium" :class="normalityStatus.textColor">
            {{ normalityStatus.message }}
          </div>
          <div class="flex space-x-1">
            <div 
              v-for="i in 5" 
              :key="i"
              class="w-2 h-2 rounded-full transition-all duration-500"
              :class="i <= normalityStatus.level ? normalityStatus.dotColor : 'bg-gray-200'"
            ></div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Chart Container -->
    <div class="relative w-full bg-slate-800/50 rounded-lg border-2 border-dashed border-slate-600/30" style="height: 400px;">
      <!-- Celebration Effects -->
      <div v-if="normalityStatus.level >= 4" class="absolute inset-0 pointer-events-none overflow-hidden rounded-lg z-30">
        <!-- Confetti Drop -->
        <div 
          v-for="confetti in confettiPieces" 
          :key="confetti.id"
          class="absolute text-3xl animate-confetti-fall"
          :style="{
            left: confetti.x + '%',
            animationDelay: confetti.delay + 'ms',
            animationDuration: confetti.duration + 'ms',
            fontSize: confetti.size + 'px'
          }"
        >
          {{ confetti.emoji }}
        </div>
        
        <!-- Rainbow Background Pulse for Level 5 -->
        <div v-if="normalityStatus.level >= 5" class="absolute inset-0 animate-rainbow-pulse opacity-10 rounded-lg"></div>
      </div>
      
      <!-- Ribbon Shower for Perfect Normality -->
      <div v-if="normalityStatus.level >= 5" id="ribbon-container" class="absolute inset-0 pointer-events-none overflow-hidden z-40"></div>
      
      <!-- Glow Effect for High Normality -->
      <div 
        v-if="normalityStatus.level >= 3"
        class="absolute inset-0 rounded-lg animate-pulse"
        :class="normalityStatus.glowClass"
      ></div>
      
      <canvas 
        ref="chartCanvas" 
        class="absolute inset-0 w-full h-full z-10"
        style="display: block;"
      ></canvas>
      
      <!-- Loading/Empty States -->
      <div v-if="data.length === 0" class="absolute inset-0 flex items-center justify-center">
        <div class="text-slate-400 text-center">
          <div class="text-4xl mb-2">🧪</div>
          <div class="text-lg font-medium text-cyan-300">Start your experiment!</div>
          <div class="text-sm mt-1 text-slate-300">Add proportion values above to generate the distribution</div>
        </div>
      </div>
      
      <div v-else-if="!chartInitialized" class="absolute inset-0 flex items-center justify-center bg-slate-800/75">
        <div class="text-cyan-300 text-center">
          <div class="animate-spin w-8 h-8 border-4 border-cyan-500 border-t-transparent rounded-full mx-auto mb-2"></div>
          <div>Loading chart...</div>
        </div>
      </div>
    </div>
    
    <!-- Celebration Message -->
    <div v-if="normalityStatus.level >= 4" class="mt-4 text-center">
      <div class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-full font-semibold animate-bounce">
        🧪 Experiment Success! Perfect Normal Distribution! 🎉
      </div>
    </div>
    <div v-else-if="normalityStatus.level >= 3" class="mt-4 text-center">
      <div class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-cyan-500 to-purple-500 text-white rounded-full font-semibold">
        ⚗️ Excellent! Your data is approaching normality! ✨
      </div>
    </div>
    
    <div class="mt-4 text-sm text-slate-300 text-center">
      This histogram shows the distribution of all proportion values collected in the lab
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { Chart, registerables } from 'chart.js'

// Register all Chart.js components
Chart.register(...registerables)

const props = defineProps({
  data: {
    type: Array,
    required: true,
    default: () => []
  },
  showTheoretical: {
    type: Boolean,
    default: false
  }
})

const chartCanvas = ref(null)
const chartInitialized = ref(false)
let chartInstance = null

// Celebration and normality detection
const normalityStatus = ref({
  level: 0,
  message: '',
  textColor: 'text-gray-500',
  dotColor: 'bg-gray-400',
  glowClass: ''
})

const confettiPieces = ref([])

// Calculate normality metrics
const calculateNormality = (values) => {
  if (!values || values.length < 5) return 0

  // Calculate basic statistics
  const n = values.length
  const mean = values.reduce((sum, val) => sum + val, 0) / n
  
  // Calculate variance and standard deviation
  const variance = values.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / (n - 1)
  const stdDev = Math.sqrt(variance)
  
  if (stdDev === 0) return 0
  
  // Calculate skewness (measure of asymmetry)
  const skewness = values.reduce((sum, val) => {
    return sum + Math.pow((val - mean) / stdDev, 3)
  }, 0) / n
  
  // Calculate kurtosis (measure of tail heaviness)
  const kurtosis = values.reduce((sum, val) => {
    return sum + Math.pow((val - mean) / stdDev, 4)
  }, 0) / n - 3
  
  // Score based on how close to normal distribution
  let normalityScore = 0
  
  // Check sample size (more data = more reliable)
  if (n >= 15) normalityScore += 1
  if (n >= 30) normalityScore += 1
  
  // Check skewness (should be close to 0 for normal distribution)
  const absSkewness = Math.abs(skewness)
  if (absSkewness < 0.5) normalityScore += 2
  else if (absSkewness < 1.0) normalityScore += 1
  
  // Check kurtosis (should be close to 0 for normal distribution)  
  const absKurtosis = Math.abs(kurtosis)
  if (absKurtosis < 0.5) normalityScore += 1
  else if (absKurtosis < 1.0) normalityScore += 0.5
  
  // Check if data is reasonably spread (not all clustered)
  const range = Math.max(...values) - Math.min(...values)
  if (range > 0.3) normalityScore += 0.5
  
  return Math.min(5, Math.max(0, Math.floor(normalityScore)))
}

// Update normality status
const updateNormalityStatus = () => {
  const level = calculateNormality(props.data)
  
  let message = ''
  let textColor = 'text-gray-500'
  let dotColor = 'bg-gray-400'
  let glowClass = ''
  
  switch (level) {
    case 0:
    case 1:
      message = 'Getting started...'
      textColor = 'text-gray-500'
      dotColor = 'bg-gray-400'
      break
    case 2:
      message = 'Taking shape!'
      textColor = 'text-blue-600'
      dotColor = 'bg-blue-400'
      break
    case 3:
      message = 'Looking good!'
      textColor = 'text-purple-600'
      dotColor = 'bg-purple-400'
      glowClass = 'shadow-lg shadow-purple-200'
      break
    case 4:
      message = 'Almost normal!'
      textColor = 'text-indigo-600'
      dotColor = 'bg-indigo-400'
      glowClass = 'shadow-xl shadow-indigo-300'
      break
    case 5:
      message = 'Perfect normal!'
      textColor = 'text-pink-600'
      dotColor = 'bg-gradient-to-r from-purple-400 to-pink-400'
      glowClass = 'shadow-2xl shadow-pink-300'
      generateConfettiPieces()
      // Trigger ribbon shower for perfect normality
      setTimeout(() => createRibbonShower(), 1000)
      break
  }
  
  normalityStatus.value = { level, message, textColor, dotColor, glowClass }
}

// Generate confetti pieces for celebration
const generateConfettiPieces = () => {
  confettiPieces.value = []
  for (let i = 0; i < 50; i++) {
    confettiPieces.value.push({
      id: i,
      x: Math.random() * 100,
      delay: Math.random() * 3000,
      duration: 2000 + Math.random() * 2000,
      size: Math.random() * 20 + 15,
      emoji: getRandomEmoji()
    })
  }
  
  // Generate new confetti every 500ms for continuous effect
  setTimeout(() => {
    if (normalityStatus.value.level >= 4) {
      generateConfettiPieces()
    }
  }, 500)
}

// Create ribbon shower effect for perfect normality
const createRibbonShower = () => {
  if (normalityStatus.value.level < 5) return
  
  const container = document.getElementById('ribbon-container')
  if (!container) return
  
  // Create multiple ribbons
  for (let i = 0; i < 20; i++) {
    setTimeout(() => {
      const ribbon = document.createElement('div')
      ribbon.className = 'ribbon-particle'
      ribbon.style.left = Math.random() * 100 + '%'
      ribbon.style.top = '-20px'
      ribbon.style.width = '4px'
      ribbon.style.height = '50px'
      ribbon.style.background = `linear-gradient(45deg, 
        hsl(${Math.random() * 360}, 70%, 60%), 
        hsl(${Math.random() * 360}, 70%, 70%))`
      ribbon.style.animationDuration = (3 + Math.random() * 2) + 's'
      ribbon.style.animationDelay = Math.random() * 2 + 's'
      ribbon.style.borderRadius = '2px'
      ribbon.style.boxShadow = '0 0 10px rgba(255,255,255,0.3)'
      
      container.appendChild(ribbon)
      
      // Remove ribbon after animation
      setTimeout(() => {
        if (ribbon.parentNode) {
          ribbon.parentNode.removeChild(ribbon)
        }
      }, 6000)
    }, i * 100)
  }
  
  // Continue creating ribbons every 2 seconds for perfect normality
  setTimeout(() => {
    if (normalityStatus.value.level >= 5) {
      createRibbonShower()
    }
  }, 2000)
}

// Get random emoji
const getRandomEmoji = () => {
  const emojis = ['🎉', '✨', '🎊', '🌟', '🎈', '🎆', '🥳', '👏', '🤩', '🏆', '🥇', '🌈', '💫', '⭐', '🎯']
  return emojis[Math.floor(Math.random() * emojis.length)]
}

// Get bar colors based on normality level
const getBarColors = (level) => {
  switch (level) {
    case 0:
    case 1:
      return {
        backgroundColor: 'rgba(59, 130, 246, 0.8)',
        borderColor: 'rgba(59, 130, 246, 1)'
      }
    case 2:
      return {
        backgroundColor: 'rgba(99, 102, 241, 0.8)',
        borderColor: 'rgba(99, 102, 241, 1)'
      }
    case 3:
      return {
        backgroundColor: 'rgba(139, 92, 246, 0.8)',
        borderColor: 'rgba(139, 92, 246, 1)'
      }
    case 4:
      return {
        backgroundColor: 'rgba(168, 85, 247, 0.8)',
        borderColor: 'rgba(168, 85, 247, 1)'
      }
    case 5:
      // Rainbow gradient effect for perfect normal
      return {
        backgroundColor: [
          'rgba(239, 68, 68, 0.8)',   // red
          'rgba(249, 115, 22, 0.8)',  // orange  
          'rgba(245, 158, 11, 0.8)',  // yellow
          'rgba(34, 197, 94, 0.8)',   // green
          'rgba(59, 130, 246, 0.8)',  // blue
          'rgba(139, 92, 246, 0.8)',  // purple
          'rgba(236, 72, 153, 0.8)'   // pink
        ],
        borderColor: [
          'rgba(239, 68, 68, 1)',
          'rgba(249, 115, 22, 1)',
          'rgba(245, 158, 11, 1)',
          'rgba(34, 197, 94, 1)',
          'rgba(59, 130, 246, 1)',
          'rgba(139, 92, 246, 1)',
          'rgba(236, 72, 153, 1)'
        ]
      }
    default:
      return {
        backgroundColor: 'rgba(59, 130, 246, 0.8)',
        borderColor: 'rgba(59, 130, 246, 1)'
      }
  }
}

// Create histogram bins and counts
const createHistogramData = (values) => {
  if (!values || values.length === 0) {
    return { labels: [], counts: [] }
  }

  // Determine bin parameters
  const min = Math.max(0, Math.min(...values) - 0.05)
  const max = Math.min(1, Math.max(...values) + 0.05)
  const range = max - min
  const numBins = Math.max(5, Math.min(12, Math.ceil(Math.sqrt(values.length))))
  const binWidth = range / numBins

  const labels = []
  const counts = new Array(numBins).fill(0)

  // Create bin labels and count values
  for (let i = 0; i < numBins; i++) {
    const binStart = min + i * binWidth
    const binEnd = min + (i + 1) * binWidth
    labels.push(`${binStart.toFixed(2)} - ${binEnd.toFixed(2)}`)

    // Count values in this bin
    values.forEach(value => {
      if (i === numBins - 1) {
        // Last bin includes upper bound
        if (value >= binStart && value <= binEnd) {
          counts[i]++
        }
      } else {
        // Other bins exclude upper bound
        if (value >= binStart && value < binEnd) {
          counts[i]++
        }
      }
    })
  }

  return { labels, counts }
}

// Initialize chart
const initializeChart = () => {
  if (!chartCanvas.value) {
    console.error('Canvas element not found')
    return
  }

  // Destroy existing chart
  if (chartInstance) {
    chartInstance.destroy()
    chartInstance = null
  }

  try {
    const ctx = chartCanvas.value.getContext('2d')
    
    chartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: [],
        datasets: [{
          label: 'Frequency',
          data: [],
          backgroundColor: 'rgba(59, 130, 246, 0.8)',
          borderColor: 'rgba(59, 130, 246, 1)',
          borderWidth: 1,
          borderRadius: 0,
          borderSkipped: false,
          categoryPercentage: 1.0,
          barPercentage: 1.0,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              title: function(context) {
                return `Range: ${context[0].label}`
              },
              label: function(context) {
                const total = props.data.length
                const percentage = total > 0 ? ((context.parsed.y / total) * 100).toFixed(1) : '0'
                return `Count: ${context.parsed.y} (${percentage}%)`
              }
            },
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            titleColor: 'white',
            bodyColor: 'white',
            borderColor: 'rgba(59, 130, 246, 1)',
            borderWidth: 1
          }
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Proportion Value Range',
              font: {
                size: 14,
                weight: 'bold'
              },
              color: '#374151'
            },
            grid: {
              display: false
            },
            ticks: {
              font: {
                size: 11
              },
              color: '#6B7280',
              maxRotation: 45
            }
          },
          y: {
            title: {
              display: true,
              text: 'Frequency (Count)',
              font: {
                size: 14,
                weight: 'bold'
              },
              color: '#374151'
            },
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 0, 0, 0.1)',
              lineWidth: 1
            },
            ticks: {
              stepSize: 1,
              font: {
                size: 11
              },
              color: '#6B7280',
              callback: function(value) {
                return Number.isInteger(value) ? value : ''
              }
            }
          }
        },
        animation: {
          duration: 800,
          easing: 'easeInOutQuart'
        },
        elements: {
          bar: {
            borderWidth: 1,
            borderColor: 'rgba(59, 130, 246, 1)'
          }
        }
      }
    })

    chartInitialized.value = true
    console.log('Chart initialized successfully')
    
    // Update with current data
    updateChart()
    
  } catch (error) {
    console.error('Failed to initialize chart:', error)
    chartInitialized.value = false
  }
}

// Update chart with new data
const updateChart = () => {
  if (!chartInstance || !chartInitialized.value) {
    console.log('Chart not ready for update')
    return
  }

  const { labels, counts } = createHistogramData(props.data)
  
  // Update normality status
  updateNormalityStatus()
  
  // Get colors based on normality level
  const colors = getBarColors(normalityStatus.value.level)
  
  console.log('Updating chart with:', { labels, counts, dataLength: props.data.length, normalityLevel: normalityStatus.value.level })

  chartInstance.data.labels = labels
  chartInstance.data.datasets[0].data = counts
  chartInstance.data.datasets[0].backgroundColor = colors.backgroundColor
  chartInstance.data.datasets[0].borderColor = colors.borderColor

  // Update y-axis max
  const maxCount = Math.max(...counts, 1)
  chartInstance.options.scales.y.max = maxCount + Math.ceil(maxCount * 0.1)

  chartInstance.update('active')
}

// Watch for data changes
watch(() => props.data, () => {
  console.log('Data changed, length:', props.data.length)
  if (chartInitialized.value) {
    updateChart()
  } else if (props.data.length > 0) {
    // Initialize chart if we have data but no chart yet
    nextTick(() => {
      if (chartCanvas.value) {
        initializeChart()
      }
    })
  }
}, { deep: true, immediate: true })

// Component lifecycle
onMounted(async () => {
  console.log('DistributionChart mounted')
  await nextTick()
  
  if (chartCanvas.value) {
    setTimeout(() => {
      initializeChart()
    }, 100)
  } else {
    console.error('Canvas ref not available on mount')
  }
})

onUnmounted(() => {
  if (chartInstance) {
    chartInstance.destroy()
    chartInstance = null
  }
  chartInitialized.value = false
})
</script>

<style scoped>
canvas {
  background-color: white;
  border-radius: 0.5rem;
}

/* Confetti drop animation */
@keyframes confetti-fall {
  0% {
    transform: translateY(-100vh) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(360deg);
    opacity: 0;
  }
}

.animate-confetti-fall {
  animation: confetti-fall 3s linear infinite;
}

/* Rainbow background pulse */
@keyframes rainbow-pulse {
  0% { background: linear-gradient(45deg, rgba(255,0,150,0.1), rgba(0,255,255,0.1)); }
  25% { background: linear-gradient(45deg, rgba(255,255,0,0.1), rgba(255,0,150,0.1)); }
  50% { background: linear-gradient(45deg, rgba(0,255,255,0.1), rgba(255,255,0,0.1)); }
  75% { background: linear-gradient(45deg, rgba(150,0,255,0.1), rgba(0,255,255,0.1)); }
  100% { background: linear-gradient(45deg, rgba(255,0,150,0.1), rgba(0,255,255,0.1)); }
}

.animate-rainbow-pulse {
  animation: rainbow-pulse 2s ease-in-out infinite;
}

/* Glow effects */
@keyframes glow {
  0%, 100% {
    box-shadow: 0 0 5px rgba(139, 92, 246, 0.3);
  }
  50% {
    box-shadow: 0 0 20px rgba(139, 92, 246, 0.6), 0 0 30px rgba(139, 92, 246, 0.4);
  }
}

.animate-glow {
  animation: glow 2s ease-in-out infinite;
}
</style> 