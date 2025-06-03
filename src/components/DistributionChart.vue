<template>
  <div class="bg-white rounded-lg p-4 border shadow-sm" data-chart>
    <div class="mb-4 flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-800">Distribution of Entered Proportions</h3>
      <div class="text-sm text-gray-600">
        {{ data.length }} values entered
      </div>
    </div>
    
    <!-- Chart Container -->
    <div class="relative w-full bg-gray-50 rounded-lg border-2 border-dashed border-gray-200" style="height: 400px;">
      <canvas 
        ref="chartCanvas" 
        class="absolute inset-0 w-full h-full"
        style="display: block;"
      ></canvas>
      
      <!-- Loading/Empty States -->
      <div v-if="data.length === 0" class="absolute inset-0 flex items-center justify-center">
        <div class="text-gray-400 text-center">
          <div class="text-4xl mb-2">📊</div>
          <div class="text-lg font-medium">Enter some data to see the distribution</div>
          <div class="text-sm mt-1">Add proportion values above to generate the histogram</div>
        </div>
      </div>
      
      <div v-else-if="!chartInitialized" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75">
        <div class="text-gray-600 text-center">
          <div class="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-2"></div>
          <div>Loading chart...</div>
        </div>
      </div>
    </div>
    
    <div class="mt-4 text-sm text-gray-600 text-center">
      This histogram shows the distribution of all proportion values entered by participants
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
  
  console.log('Updating chart with:', { labels, counts, dataLength: props.data.length })

  chartInstance.data.labels = labels
  chartInstance.data.datasets[0].data = counts

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
</style> 