<script setup lang="ts">
import {
  CategoryScale,
  Chart as ChartJS,
  Filler,
  LinearScale,
  LineElement,
  PointElement,
  Tooltip,
  type ChartData,
  type ChartOptions,
} from 'chart.js'
import { computed } from 'vue'
import { Line } from 'vue-chartjs'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Filler, Tooltip)

const props = defineProps<{
  labels: string[]
  values: number[]
}>()

const chartData = computed<ChartData<'line'>>(() => ({
  labels: props.labels,
  datasets: [
    {
      label: 'Posjete',
      data: props.values,
      borderColor: 'rgb(8 145 178)',
      backgroundColor: 'rgba(34, 211, 238, 0.16)',
      pointBackgroundColor: 'rgb(8 145 178)',
      pointBorderColor: 'white',
      pointBorderWidth: 2,
      pointRadius: 4,
      tension: 0.4,
      fill: true,
    },
  ],
}))

const chartOptions: ChartOptions<'line'> = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: 'rgb(30 41 59)',
      padding: 10,
      cornerRadius: 8,
      displayColors: false,
    },
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: { color: '#94a3b8' },
    },
    y: {
      beginAtZero: true,
      grid: { color: 'rgba(148, 163, 184, 0.15)' },
      ticks: { color: '#94a3b8' },
    },
  },
}
</script>

<template>
  <div class="h-64">
    <Line :data="chartData" :options="chartOptions" />
  </div>
</template>
