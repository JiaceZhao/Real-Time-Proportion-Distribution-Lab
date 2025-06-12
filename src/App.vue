<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-indigo-900">
    <!-- Header -->
    <header class="glass-effect">
      <div class="max-w-7xl mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <div class="w-12 h-12 flex items-center justify-center">
              <FlaskIcon :size="48" />
            </div>
            <div>
              <h1 class="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-purple-400">PROPORTION LAB</h1>
              <p class="text-sm text-cyan-200">AP STATISTICS • Class of 2025</p>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <a 
              href="https://github.com/JiaceZhao/Real-Time-Proportion-Distribution-Lab"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-secondary flex items-center space-x-2 hover:bg-gray-100 transition-colors"
              title="View on GitHub"
            >
              <Github class="w-4 h-4" />
              <span class="hidden sm:inline">GitHub</span>
            </a>
            <button 
              @click="resetData"
              class="btn-secondary flex items-center space-x-2"
            >
              <RotateCcw class="w-4 h-4" />
              <span>Reset</span>
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-6 py-8 space-y-8">
      <!-- Data Entry Interface -->
      <div class="card">
        <h2 class="text-xl font-semibold mb-4 flex items-center space-x-2">
          <Plus class="w-5 h-5 text-primary-600" />
          <span>Enter Proportion Data</span>
        </h2>
        
        <div class="bg-gradient-to-r from-slate-800/50 to-blue-900/50 rounded-xl p-8 border border-slate-600/30">
          <div class="max-w-md mx-auto space-y-6">
            <div>
              <label class="block text-lg font-medium text-cyan-200 mb-3">
                Enter a proportion value (between 0 and 1):
              </label>
              <div class="flex space-x-3">
                <input 
                  v-model="inputProportion"
                  type="number" 
                  min="0" 
                  max="1" 
                  step="0.001"
                  placeholder="e.g., 0.65"
                  class="flex-1 px-4 py-3 border border-slate-500/30 bg-slate-700/50 text-white rounded-lg focus:ring-2 focus:ring-cyan-500 focus:border-transparent text-lg placeholder-slate-400"
                  @keyup.enter="addProportion"
                >
                <button 
                  @click="addProportion"
                  class="btn-primary px-6"
                  :disabled="!isValidInput"
                >
                  <Plus class="w-5 h-5" />
                </button>
              </div>
              <div class="mt-2 text-sm text-slate-300">
                Examples: 0.25, 0.50, 0.75 (or as percentages: 25%, 50%, 75%)
              </div>
            </div>
            
            <!-- Input Validation Message -->
            <div v-if="validationMessage" class="text-red-400 text-sm">
              {{ validationMessage }}
            </div>
          </div>
        </div>
      </div>

      <!-- Data Manager Component -->
      <DataManager 
        :current-data="proportionData"
        @dataLoaded="handleDataLoaded"
        @dataImported="handleDataImported"
      />

      <!-- Recent Entries -->
      <div v-if="proportionData.length > 0" class="card">
        <h2 class="text-xl font-semibold mb-4 flex items-center space-x-2">
          <List class="w-5 h-5 text-primary-600" />
          <span>Recent Entries</span>
        </h2>
        
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div class="stat-card">
            <div class="text-2xl font-bold text-cyan-400">{{ proportionData.length }}</div>
            <div class="text-sm text-slate-300">Total Entries</div>
          </div>
          <div class="stat-card">
            <div class="text-2xl font-bold text-blue-400">{{ meanProportion.toFixed(3) }}</div>
            <div class="text-sm text-slate-300">Mean</div>
          </div>
          <div class="stat-card">
            <div class="text-2xl font-bold text-purple-400">{{ stdDeviation.toFixed(3) }}</div>
            <div class="text-sm text-slate-300">Std Deviation</div>
          </div>
          <div class="stat-card">
            <div class="text-2xl font-bold text-pink-400">{{ (rangeValue * 100).toFixed(1) }}%</div>
            <div class="text-sm text-slate-300">Range</div>
          </div>
        </div>
        
        <!-- Recent Values Display -->
        <div class="bg-slate-700/30 rounded-lg p-4 border border-slate-600/30">
          <h3 class="font-semibold mb-3 text-cyan-200">Last {{ Math.min(10, proportionData.length) }} entries:</h3>
          <div class="flex flex-wrap gap-2">
            <div 
              v-for="(value, index) in recentEntries" 
              :key="index"
              class="px-3 py-1 bg-gradient-to-r from-cyan-500/20 to-purple-500/20 text-cyan-200 border border-cyan-500/30 rounded-full text-sm font-medium animate-fade-in"
              :style="{ animationDelay: `${index * 100}ms` }"
            >
              {{ value.toFixed(3) }}
            </div>
          </div>
        </div>
      </div>

      <!-- Distribution Visualization -->
      <div v-if="proportionData.length > 0" class="card">
        <h2 class="text-xl font-semibold mb-4 flex items-center space-x-2">
          <TrendingUp class="w-5 h-5 text-primary-600" />
          <span>Proportion Distribution</span>
        </h2>
        
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div class="lg:col-span-2">
            <DistributionChart 
              :data="proportionData"
              :show-theoretical="false"
            />
          </div>
          
          <div class="space-y-4">
            <div class="stat-card">
              <div class="text-lg font-semibold text-cyan-200 mb-2">Lab Results Summary</div>
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-slate-300">Sample Size:</span>
                  <span class="font-semibold text-cyan-300">{{ proportionData.length }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-300">Mean:</span>
                  <span class="font-semibold text-blue-300">{{ meanProportion.toFixed(3) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-300">Median:</span>
                  <span class="font-semibold text-purple-300">{{ medianProportion.toFixed(3) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-300">Std Dev:</span>
                  <span class="font-semibold text-pink-300">{{ stdDeviation.toFixed(3) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-300">Min:</span>
                  <span class="font-semibold text-green-300">{{ minValue.toFixed(3) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-slate-300">Max:</span>
                  <span class="font-semibold text-yellow-300">{{ maxValue.toFixed(3) }}</span>
                </div>
              </div>
            </div>
            
            <div class="stat-card">
              <div class="text-lg font-semibold text-cyan-200 mb-2">Distribution Analysis</div>
              <div class="text-sm text-slate-300 leading-relaxed">
                As more students contribute their proportion values, observe how the data distributes and approaches normality. Look for the bell curve pattern!
              </div>
            </div>
            
            <div class="stat-card">
              <div class="text-lg font-semibold text-cyan-200 mb-2">Lab Instructions</div>
              <div class="text-sm text-slate-300 leading-relaxed">
                Each student should enter their calculated proportion value. The histogram updates in real-time to show the class distribution.
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Getting Started Message -->
      <div v-else class="card text-center">
        <div class="max-w-md mx-auto space-y-4">
          <div class="w-16 h-16 bg-gradient-to-r from-cyan-500/20 to-purple-500/20 rounded-full flex items-center justify-center mx-auto border border-cyan-500/30">
            <FlaskIcon :size="32" />
          </div>
          <h3 class="text-xl font-semibold text-cyan-200">Begin Your Experiment!</h3>
          <p class="text-slate-300">
            Start entering proportion values to see the distribution build up in real-time. 
            Each student can contribute their calculated data point to the lab.
          </p>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="bg-slate-800/50 border-t border-slate-600/30 mt-16">
      <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="flex flex-col items-center justify-center space-y-4">
          <div class="flex items-center space-x-2 text-cyan-200">
            <FlaskIcon :size="20" />
            <span class="font-semibold">PROPORTION LAB</span>
          </div>
          <div class="text-center text-sm text-slate-300 space-y-2">
            <div class="flex items-center justify-center space-x-4">
              <span>👨‍💻 Created by <strong>JiaceZhao</strong></span>
              <span>•</span>
              <a 
                href="https://github.com/JiaceZhao/Real-Time-Proportion-Distribution-Lab"
                target="_blank"
                rel="noopener noreferrer"
                class="text-cyan-400 hover:text-cyan-300 transition-colors flex items-center space-x-1"
              >
                <Github class="w-4 h-4" />
                <span>View Source</span>
              </a>
            </div>
            <div>
              AP Statistics Class of 2025 • Interactive Laboratory Experience
            </div>
            <div class="text-xs">
              MIT License - Free for educational and commercial use
            </div>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { Plus, List, TrendingUp, RotateCcw, Github } from 'lucide-vue-next'
import DistributionChart from './components/DistributionChart.vue'
import DataManager from './components/DataManager.vue'
import FlaskIcon from './components/FlaskIcon.vue'

// Reactive state
const inputProportion = ref('')
const proportionData = ref([])
const validationMessage = ref('')

// Local storage key for current session auto-save
const CURRENT_SESSION_KEY = 'current_proportion_session'

// Computed properties
const isValidInput = computed(() => {
  const value = parseFloat(inputProportion.value)
  return !isNaN(value) && value >= 0 && value <= 1
})

const meanProportion = computed(() => {
  if (proportionData.value.length === 0) return 0
  const sum = proportionData.value.reduce((acc, prop) => acc + prop, 0)
  return sum / proportionData.value.length
})

const medianProportion = computed(() => {
  if (proportionData.value.length === 0) return 0
  const sorted = [...proportionData.value].sort((a, b) => a - b)
  const mid = Math.floor(sorted.length / 2)
  return sorted.length % 2 === 0 
    ? (sorted[mid - 1] + sorted[mid]) / 2 
    : sorted[mid]
})

const stdDeviation = computed(() => {
  if (proportionData.value.length < 2) return 0
  const mean = meanProportion.value
  const variance = proportionData.value.reduce((acc, prop) => acc + Math.pow(prop - mean, 2), 0) / (proportionData.value.length - 1)
  return Math.sqrt(variance)
})

const minValue = computed(() => {
  return proportionData.value.length > 0 ? Math.min(...proportionData.value) : 0
})

const maxValue = computed(() => {
  return proportionData.value.length > 0 ? Math.max(...proportionData.value) : 0
})

const rangeValue = computed(() => {
  return maxValue.value - minValue.value
})

const recentEntries = computed(() => {
  return [...proportionData.value].reverse().slice(0, 10)
})

// Methods
const addProportion = () => {
  validationMessage.value = ''
  
  // Handle percentage input (e.g., "50%" -> 0.5)
  let inputValue = inputProportion.value.toString().trim()
  if (inputValue.endsWith('%')) {
    inputValue = inputValue.slice(0, -1)
    const percentValue = parseFloat(inputValue)
    if (!isNaN(percentValue) && percentValue >= 0 && percentValue <= 100) {
      inputValue = (percentValue / 100).toString()
    }
  }
  
  const value = parseFloat(inputValue)
  
  if (isNaN(value)) {
    validationMessage.value = 'Please enter a valid number'
    return
  }
  
  if (value < 0 || value > 1) {
    validationMessage.value = 'Please enter a value between 0 and 1 (or 0% and 100%)'
    return
  }
  
  proportionData.value.push(value)
  inputProportion.value = ''
  
  // Auto-save current session
  saveCurrentSession()
  
  // Optional: scroll to histogram
  if (proportionData.value.length === 1) {
    setTimeout(() => {
      document.querySelector('[data-chart]')?.scrollIntoView({ behavior: 'smooth' })
    }, 100)
  }
}

const resetData = () => {
  if (proportionData.value.length > 0) {
    if (confirm('确定要重置当前数据吗？建议先保存当前会话再重置。')) {
      proportionData.value = []
      inputProportion.value = ''
      validationMessage.value = ''
      localStorage.removeItem(CURRENT_SESSION_KEY)
    }
  } else {
    proportionData.value = []
    inputProportion.value = ''
    validationMessage.value = ''
  }
}

// Handle events from DataManager
const handleDataLoaded = (data) => {
  proportionData.value = [...data]
  saveCurrentSession()
}

const handleDataImported = (data) => {
  proportionData.value = [...data]
  saveCurrentSession()
}

// Auto-save current session
const saveCurrentSession = () => {
  try {
    if (proportionData.value.length > 0) {
      localStorage.setItem(CURRENT_SESSION_KEY, JSON.stringify(proportionData.value))
    } else {
      localStorage.removeItem(CURRENT_SESSION_KEY)
    }
  } catch (error) {
    console.error('Failed to save current session:', error)
  }
}

// Load current session on startup
const loadCurrentSession = () => {
  try {
    const saved = localStorage.getItem(CURRENT_SESSION_KEY)
    if (saved) {
      const data = JSON.parse(saved)
      if (Array.isArray(data) && data.length > 0) {
        proportionData.value = data
      }
    }
  } catch (error) {
    console.error('Failed to load current session:', error)
  }
}

// Lifecycle
onMounted(() => {
  loadCurrentSession()
})

// Watch for data changes to auto-save
watch(proportionData, () => {
  saveCurrentSession()
}, { deep: true })
</script>

<style scoped>
.slider::-webkit-slider-thumb {
  @apply appearance-none w-6 h-6 bg-primary-500 rounded-full cursor-pointer hover:bg-primary-600 transition-colors;
}

.slider::-moz-range-thumb {
  @apply w-6 h-6 bg-primary-500 rounded-full cursor-pointer border-0 hover:bg-primary-600 transition-colors;
}
</style> 