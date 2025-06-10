<template>
  <div class="bg-white rounded-lg p-4 border shadow-sm">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-800 flex items-center space-x-2">
        <Database class="w-5 h-5 text-primary-600" />
        <span>数据管理 (Data Management)</span>
      </h3>
      <div class="flex items-center space-x-2">
        <span class="text-sm text-gray-600">
          已保存 {{ savedSessions.length }} 个会话
        </span>
        <button
          @click="saveCurrentSession"
          :disabled="currentData.length === 0"
          class="btn-sm bg-green-500 hover:bg-green-600 text-white disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-1"
        >
          <Save class="w-4 h-4" />
          <span>保存当前数据</span>
        </button>
      </div>
    </div>

    <!-- 当前会话统计 -->
    <div v-if="currentData.length > 0" class="bg-blue-50 rounded-lg p-4 mb-4">
      <h4 class="font-medium text-blue-900 mb-2">当前会话</h4>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
        <div>
          <span class="text-blue-600">数据点:</span>
          <span class="font-semibold ml-1">{{ currentData.length }}</span>
        </div>
        <div>
          <span class="text-blue-600">平均值:</span>
          <span class="font-semibold ml-1">{{ currentMean.toFixed(3) }}</span>
        </div>
        <div>
          <span class="text-blue-600">标准差:</span>
          <span class="font-semibold ml-1">{{ currentStdDev.toFixed(3) }}</span>
        </div>
        <div>
          <span class="text-blue-600">范围:</span>
          <span class="font-semibold ml-1">{{ currentRange.toFixed(3) }}</span>
        </div>
      </div>
    </div>

    <!-- 历史会话列表 -->
    <div v-if="savedSessions.length > 0" class="space-y-3">
      <h4 class="font-medium text-gray-900 flex items-center space-x-2">
        <History class="w-4 h-4" />
        <span>历史会话记录</span>
      </h4>
      
      <div class="max-h-64 overflow-y-auto space-y-2">
        <div 
          v-for="(session, index) in savedSessions" 
          :key="session.id"
          class="bg-gray-50 rounded-lg p-3 hover:bg-gray-100 transition-colors"
        >
          <div class="flex items-center justify-between">
            <div class="flex-1">
              <div class="flex items-center space-x-4 text-sm">
                <span class="font-medium text-gray-900">
                  会话 #{{ savedSessions.length - index }}
                </span>
                <span class="text-gray-600">
                  {{ formatDate(session.timestamp) }}
                </span>
                <span class="text-blue-600">
                  {{ session.data.length }} 个数据点
                </span>
                <span class="text-green-600">
                  均值: {{ session.statistics.mean.toFixed(3) }}
                </span>
              </div>
              <div class="mt-1 text-xs text-gray-500">
                范围: {{ session.statistics.min.toFixed(3) }} - {{ session.statistics.max.toFixed(3) }} | 
                标准差: {{ session.statistics.stdDev.toFixed(3) }}
              </div>
            </div>
            <div class="flex items-center space-x-2">
              <button
                @click="loadSession(session)"
                class="btn-xs bg-blue-500 hover:bg-blue-600 text-white flex items-center space-x-1"
                title="加载此会话数据"
              >
                <Download class="w-3 h-3" />
                <span>加载</span>
              </button>
              <button
                @click="deleteSession(session.id)"
                class="btn-xs bg-red-500 hover:bg-red-600 text-white flex items-center space-x-1"
                title="删除此会话"
              >
                <Trash2 class="w-3 h-3" />
                <span>删除</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 导出选项 -->
    <div class="mt-6 pt-4 border-t border-gray-200">
      <h4 class="font-medium text-gray-900 mb-3 flex items-center space-x-2">
        <FileText class="w-4 h-4" />
        <span>数据导出</span>
      </h4>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
        <button
          @click="exportCurrentToExcel"
          :disabled="currentData.length === 0"
          class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
        >
          <FileSpreadsheet class="w-4 h-4" />
          <span>导出当前数据</span>
        </button>
        
        <button
          @click="exportAllToExcel"
          :disabled="savedSessions.length === 0"
          class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
        >
          <Layers class="w-4 h-4" />
          <span>导出所有会话</span>
        </button>
        
        <button
          @click="exportSummaryToExcel"
          :disabled="savedSessions.length === 0"
          class="btn-secondary disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
        >
          <BarChart3 class="w-4 h-4" />
          <span>导出统计摘要</span>
        </button>
      </div>
      
      <div class="mt-3 text-xs text-gray-500">
        💡 提示: Excel文件将包含所有输入的比例值、时间戳和统计信息
      </div>
    </div>

    <!-- 数据清理 -->
    <div class="mt-6 pt-4 border-t border-gray-200">
      <h4 class="font-medium text-gray-900 mb-3 flex items-center space-x-2">
        <Settings class="w-4 h-4" />
        <span>数据管理</span>
      </h4>
      
      <div class="flex items-center space-x-3">
        <button
          @click="clearAllData"
          :disabled="savedSessions.length === 0 && currentData.length === 0"
          class="btn-sm bg-red-500 hover:bg-red-600 text-white disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-1"
        >
          <Trash2 class="w-4 h-4" />
          <span>清除所有数据</span>
        </button>
        
        <button
          @click="showImportDialog = true"
          class="btn-sm bg-gray-500 hover:bg-gray-600 text-white flex items-center space-x-1"
        >
          <Upload class="w-4 h-4" />
          <span>导入数据</span>
        </button>
      </div>
    </div>

    <!-- 导入对话框 -->
    <div v-if="showImportDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold mb-4">导入数据</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              粘贴比例值 (每行一个，或用逗号分隔):
            </label>
            <textarea
              v-model="importText"
              rows="6"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              placeholder="例如:&#10;0.25&#10;0.50&#10;0.75&#10;或: 0.25, 0.50, 0.75"
            ></textarea>
          </div>
          <div class="flex justify-end space-x-3">
            <button
              @click="cancelImport"
              class="btn-secondary"
            >
              取消
            </button>
            <button
              @click="importData"
              :disabled="!importText.trim()"
              class="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
            >
              导入
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { 
  Database, Save, History, Download, Trash2, FileText, 
  FileSpreadsheet, BarChart3, Settings, Upload, Layers
} from 'lucide-vue-next'
import * as XLSX from 'xlsx'
import { saveAs } from 'file-saver'

const props = defineProps({
  currentData: {
    type: Array,
    required: true,
    default: () => []
  }
})

const emit = defineEmits(['dataLoaded', 'dataImported'])

// 响应式数据
const savedSessions = ref([])
const showImportDialog = ref(false)
const importText = ref('')

// 本地存储的键名
const STORAGE_KEY = 'proportion_distribution_sessions'

// 计算属性
const currentMean = computed(() => {
  if (props.currentData.length === 0) return 0
  return props.currentData.reduce((sum, val) => sum + val, 0) / props.currentData.length
})

const currentStdDev = computed(() => {
  if (props.currentData.length < 2) return 0
  const mean = currentMean.value
  const variance = props.currentData.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / (props.currentData.length - 1)
  return Math.sqrt(variance)
})

const currentRange = computed(() => {
  if (props.currentData.length === 0) return 0
  return Math.max(...props.currentData) - Math.min(...props.currentData)
})

// 方法
const generateSessionId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const calculateStatistics = (data) => {
  if (data.length === 0) return { mean: 0, stdDev: 0, min: 0, max: 0, median: 0 }
  
  const sorted = [...data].sort((a, b) => a - b)
  const mean = data.reduce((sum, val) => sum + val, 0) / data.length
  const variance = data.length > 1 ? 
    data.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / (data.length - 1) : 0
  const stdDev = Math.sqrt(variance)
  const median = sorted.length % 2 === 0 ? 
    (sorted[Math.floor(sorted.length / 2) - 1] + sorted[Math.floor(sorted.length / 2)]) / 2 :
    sorted[Math.floor(sorted.length / 2)]
  
  return {
    mean,
    stdDev,
    min: Math.min(...data),
    max: Math.max(...data),
    median
  }
}

const saveCurrentSession = () => {
  if (props.currentData.length === 0) return
  
  const session = {
    id: generateSessionId(),
    timestamp: new Date().toISOString(),
    data: [...props.currentData],
    statistics: calculateStatistics(props.currentData)
  }
  
  savedSessions.value.push(session)
  saveToLocalStorage()
  
  // 显示成功提示
  alert(`成功保存会话! 包含 ${props.currentData.length} 个数据点`)
}

const loadSession = (session) => {
  if (confirm(`确定要加载会话 "${formatDate(session.timestamp)}" 吗？这将替换当前数据。`)) {
    emit('dataLoaded', session.data)
  }
}

const deleteSession = (sessionId) => {
  if (confirm('确定要删除这个会话吗？此操作无法撤销。')) {
    savedSessions.value = savedSessions.value.filter(s => s.id !== sessionId)
    saveToLocalStorage()
  }
}

const clearAllData = () => {
  if (confirm('确定要清除所有保存的数据吗？此操作无法撤销。')) {
    savedSessions.value = []
    localStorage.removeItem(STORAGE_KEY)
    emit('dataLoaded', [])
  }
}

const formatDate = (isoString) => {
  const date = new Date(isoString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const saveToLocalStorage = () => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(savedSessions.value))
  } catch (error) {
    console.error('保存到本地存储失败:', error)
    alert('保存数据失败，请检查浏览器存储空间')
  }
}

const loadFromLocalStorage = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) {
      savedSessions.value = JSON.parse(stored)
    }
  } catch (error) {
    console.error('从本地存储加载失败:', error)
    savedSessions.value = []
  }
}

// Excel 导出功能
const exportCurrentToExcel = () => {
  if (props.currentData.length === 0) return
  
  const data = props.currentData.map((value, index) => ({
    '序号': index + 1,
    '比例值': value,
    '输入时间': new Date().toLocaleString('zh-CN')
  }))
  
  const statistics = calculateStatistics(props.currentData)
  const summaryData = [
    { '统计项': '数据点数量', '值': props.currentData.length },
    { '统计项': '平均值', '值': statistics.mean.toFixed(6) },
    { '统计项': '中位数', '值': statistics.median.toFixed(6) },
    { '统计项': '标准差', '值': statistics.stdDev.toFixed(6) },
    { '统计项': '最小值', '值': statistics.min.toFixed(6) },
    { '统计项': '最大值', '值': statistics.max.toFixed(6) },
    { '统计项': '范围', '值': (statistics.max - statistics.min).toFixed(6) }
  ]
  
  const wb = XLSX.utils.book_new()
  const wsData = XLSX.utils.json_to_sheet(data)
  const wsSummary = XLSX.utils.json_to_sheet(summaryData)
  
  XLSX.utils.book_append_sheet(wb, wsData, '原始数据')
  XLSX.utils.book_append_sheet(wb, wsSummary, '统计摘要')
  
  const fileName = `比例分布数据_${new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-')}.xlsx`
  XLSX.writeFile(wb, fileName)
}

const exportAllToExcel = () => {
  if (savedSessions.value.length === 0) return
  
  const wb = XLSX.utils.book_new()
  
  // 为每个会话创建一个工作表
  savedSessions.value.forEach((session, index) => {
    const data = session.data.map((value, dataIndex) => ({
      '序号': dataIndex + 1,
      '比例值': value,
      '会话时间': formatDate(session.timestamp)
    }))
    
    const ws = XLSX.utils.json_to_sheet(data)
    XLSX.utils.book_append_sheet(wb, ws, `会话${index + 1}`)
  })
  
  // 添加总体摘要
  const allData = savedSessions.value.flatMap(s => s.data)
  const overallStats = calculateStatistics(allData)
  const summaryData = [
    { '项目': '总会话数', '值': savedSessions.value.length },
    { '项目': '总数据点', '值': allData.length },
    { '项目': '整体平均值', '值': overallStats.mean.toFixed(6) },
    { '项目': '整体中位数', '值': overallStats.median.toFixed(6) },
    { '项目': '整体标准差', '值': overallStats.stdDev.toFixed(6) },
    { '项目': '整体最小值', '值': overallStats.min.toFixed(6) },
    { '项目': '整体最大值', '值': overallStats.max.toFixed(6) }
  ]
  
  const wsSummary = XLSX.utils.json_to_sheet(summaryData)
  XLSX.utils.book_append_sheet(wb, wsSummary, '总体摘要')
  
  const fileName = `所有会话数据_${new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-')}.xlsx`
  XLSX.writeFile(wb, fileName)
}

const exportSummaryToExcel = () => {
  if (savedSessions.value.length === 0) return
  
  const summaryData = savedSessions.value.map((session, index) => ({
    '会话编号': index + 1,
    '时间': formatDate(session.timestamp),
    '数据点数量': session.data.length,
    '平均值': session.statistics.mean.toFixed(6),
    '中位数': session.statistics.median.toFixed(6),
    '标准差': session.statistics.stdDev.toFixed(6),
    '最小值': session.statistics.min.toFixed(6),
    '最大值': session.statistics.max.toFixed(6),
    '范围': (session.statistics.max - session.statistics.min).toFixed(6)
  }))
  
  const wb = XLSX.utils.book_new()
  const ws = XLSX.utils.json_to_sheet(summaryData)
  XLSX.utils.book_append_sheet(wb, ws, '会话统计摘要')
  
  const fileName = `会话统计摘要_${new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-')}.xlsx`
  XLSX.writeFile(wb, fileName)
}

// 数据导入功能
const importData = () => {
  try {
    const text = importText.value.trim()
    if (!text) return
    
    // 支持多种分隔符
    const values = text
      .split(/[,\n\r\t\s]+/)
      .map(v => v.trim())
      .filter(v => v)
      .map(v => {
        // 处理百分号
        if (v.endsWith('%')) {
          return parseFloat(v.slice(0, -1)) / 100
        }
        return parseFloat(v)
      })
      .filter(v => !isNaN(v) && v >= 0 && v <= 1)
    
    if (values.length === 0) {
      alert('没有找到有效的比例值（应在0-1之间）')
      return
    }
    
    if (confirm(`确定要导入 ${values.length} 个数据点吗？这将替换当前数据。`)) {
      emit('dataImported', values)
      cancelImport()
    }
  } catch (error) {
    alert('导入数据时出错，请检查数据格式')
  }
}

const cancelImport = () => {
  showImportDialog.value = false
  importText.value = ''
}

// 生命周期
onMounted(() => {
  loadFromLocalStorage()
})

// 监听保存的会话变化，自动保存到本地存储
watch(savedSessions, () => {
  saveToLocalStorage()
}, { deep: true })
</script>

<style scoped>
.btn-xs {
  @apply px-2 py-1 text-xs font-medium rounded transition-colors;
}

.btn-sm {
  @apply px-3 py-1.5 text-sm font-medium rounded transition-colors;
}

.btn-secondary {
  @apply px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-lg hover:bg-gray-200 transition-colors;
}

.btn-primary {
  @apply px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-lg hover:bg-blue-700 transition-colors;
}
</style> 