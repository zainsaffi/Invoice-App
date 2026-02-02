"use client";

import { useState, useMemo } from "react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
} from "recharts";
import { formatCurrency } from "@/lib/utils";
import { TrendingUp, BarChart3, Calendar, User, Filter, X } from "lucide-react";

interface SalesData {
  date: string;
  amount: number;
  paidAt: string | null;
  clientName: string;
  clientEmail: string;
}

interface SalesChartProps {
  salesData: SalesData[];
}

type TimePeriod = "daily" | "weekly" | "monthly" | "yearly" | "all";
type ChartType = "area" | "bar";

const timePeriods: { id: TimePeriod; label: string }[] = [
  { id: "daily", label: "Daily" },
  { id: "weekly", label: "Weekly" },
  { id: "monthly", label: "Monthly" },
  { id: "yearly", label: "Yearly" },
  { id: "all", label: "All Time" },
];

const months = [
  { value: 0, label: "January" },
  { value: 1, label: "February" },
  { value: 2, label: "March" },
  { value: 3, label: "April" },
  { value: 4, label: "May" },
  { value: 5, label: "June" },
  { value: 6, label: "July" },
  { value: 7, label: "August" },
  { value: 8, label: "September" },
  { value: 9, label: "October" },
  { value: 10, label: "November" },
  { value: 11, label: "December" },
];

export default function SalesChart({ salesData }: SalesChartProps) {
  const [activePeriod, setActivePeriod] = useState<TimePeriod>("monthly");
  const [chartType, setChartType] = useState<ChartType>("area");
  const [showFilters, setShowFilters] = useState(false);

  // Filter states
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  const [selectedMonth, setSelectedMonth] = useState<number | null>(null);
  const [selectedClient, setSelectedClient] = useState<string | null>(null);

  // Get unique years from data
  const availableYears = useMemo(() => {
    const years = new Set<number>();
    salesData.forEach((d) => {
      if (d.paidAt) {
        years.add(new Date(d.paidAt).getFullYear());
      }
    });
    return Array.from(years).sort((a, b) => b - a);
  }, [salesData]);

  // Get unique clients from data
  const availableClients = useMemo(() => {
    const clients = new Map<string, string>();
    salesData.forEach((d) => {
      if (!clients.has(d.clientEmail)) {
        clients.set(d.clientEmail, d.clientName);
      }
    });
    return Array.from(clients.entries()).map(([email, name]) => ({
      email,
      name,
    })).sort((a, b) => a.name.localeCompare(b.name));
  }, [salesData]);

  // Filter sales data based on selections
  const filteredSalesData = useMemo(() => {
    return salesData.filter((d) => {
      if (!d.paidAt) return false;

      const paidDate = new Date(d.paidAt);

      // Year filter
      if (selectedYear !== null && paidDate.getFullYear() !== selectedYear) {
        return false;
      }

      // Month filter
      if (selectedMonth !== null && paidDate.getMonth() !== selectedMonth) {
        return false;
      }

      // Client filter
      if (selectedClient !== null && d.clientEmail !== selectedClient) {
        return false;
      }

      return true;
    });
  }, [salesData, selectedYear, selectedMonth, selectedClient]);

  // Check if any filters are active
  const hasActiveFilters = selectedYear !== null || selectedMonth !== null || selectedClient !== null;

  // Clear all filters
  const clearFilters = () => {
    setSelectedYear(null);
    setSelectedMonth(null);
    setSelectedClient(null);
  };

  const chartData = useMemo(() => {
    const now = new Date();
    const dataToUse = filteredSalesData;
    let dataPoints: { name: string; sales: number; date: Date }[] = [];

    switch (activePeriod) {
      case "daily": {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30);

        const dailyMap = new Map<string, number>();

        for (let i = 0; i < 30; i++) {
          const date = new Date();
          date.setDate(date.getDate() - (29 - i));
          const key = date.toISOString().split("T")[0];
          dailyMap.set(key, 0);
        }

        dataToUse.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          if (date >= startDate) {
            const key = date.toISOString().split("T")[0];
            dailyMap.set(key, (dailyMap.get(key) || 0) + d.amount);
          }
        });

        dataPoints = Array.from(dailyMap.entries()).map(([key, sales]) => ({
          name: new Date(key).toLocaleDateString("en-US", {
            month: "short",
            day: "numeric",
          }),
          sales,
          date: new Date(key),
        }));
        break;
      }

      case "weekly": {
        const weeksMap = new Map<string, number>();

        for (let i = 0; i < 12; i++) {
          const weekStart = new Date();
          weekStart.setDate(weekStart.getDate() - (11 - i) * 7);
          const weekKey = `Week ${i + 1}`;
          weeksMap.set(weekKey, 0);
        }

        dataToUse.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          const weeksAgo = Math.floor(
            (now.getTime() - date.getTime()) / (7 * 24 * 60 * 60 * 1000)
          );
          if (weeksAgo >= 0 && weeksAgo < 12) {
            const weekKey = `Week ${12 - weeksAgo}`;
            weeksMap.set(weekKey, (weeksMap.get(weekKey) || 0) + d.amount);
          }
        });

        dataPoints = Array.from(weeksMap.entries()).map(([key, sales]) => ({
          name: key,
          sales,
          date: new Date(),
        }));
        break;
      }

      case "monthly": {
        const monthsMap = new Map<string, number>();

        for (let i = 0; i < 12; i++) {
          const monthDate = new Date();
          monthDate.setMonth(monthDate.getMonth() - (11 - i));
          const key = monthDate.toLocaleDateString("en-US", {
            month: "short",
            year: "2-digit",
          });
          monthsMap.set(key, 0);
        }

        dataToUse.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          const monthsAgo =
            (now.getFullYear() - date.getFullYear()) * 12 +
            (now.getMonth() - date.getMonth());
          if (monthsAgo >= 0 && monthsAgo < 12) {
            const key = date.toLocaleDateString("en-US", {
              month: "short",
              year: "2-digit",
            });
            monthsMap.set(key, (monthsMap.get(key) || 0) + d.amount);
          }
        });

        dataPoints = Array.from(monthsMap.entries()).map(([key, sales]) => ({
          name: key,
          sales,
          date: new Date(),
        }));
        break;
      }

      case "yearly": {
        const yearsMap = new Map<string, number>();

        for (let i = 0; i < 5; i++) {
          const year = now.getFullYear() - (4 - i);
          yearsMap.set(year.toString(), 0);
        }

        dataToUse.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          const year = date.getFullYear();
          if (yearsMap.has(year.toString())) {
            yearsMap.set(
              year.toString(),
              (yearsMap.get(year.toString()) || 0) + d.amount
            );
          }
        });

        dataPoints = Array.from(yearsMap.entries()).map(([key, sales]) => ({
          name: key,
          sales,
          date: new Date(parseInt(key), 0, 1),
        }));
        break;
      }

      case "all": {
        const quartersMap = new Map<string, number>();

        dataToUse.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          const quarter = Math.floor(date.getMonth() / 3) + 1;
          const key = `Q${quarter} ${date.getFullYear()}`;
          quartersMap.set(key, (quartersMap.get(key) || 0) + d.amount);
        });

        dataPoints = Array.from(quartersMap.entries())
          .map(([key, sales]) => {
            const [q, year] = key.split(" ");
            const quarterNum = parseInt(q.replace("Q", ""));
            const date = new Date(parseInt(year), (quarterNum - 1) * 3, 1);
            return { name: key, sales, date };
          })
          .sort((a, b) => a.date.getTime() - b.date.getTime());

        if (dataPoints.length === 0) {
          for (let i = 1; i <= 4; i++) {
            dataPoints.push({
              name: `Q${i} ${now.getFullYear()}`,
              sales: 0,
              date: new Date(now.getFullYear(), (i - 1) * 3, 1),
            });
          }
        }
        break;
      }
    }

    return dataPoints;
  }, [filteredSalesData, activePeriod]);

  const totalForPeriod = useMemo(() => {
    return chartData.reduce((sum, d) => sum + d.sales, 0);
  }, [chartData]);

  const avgForPeriod = useMemo(() => {
    if (chartData.length === 0) return 0;
    return totalForPeriod / chartData.length;
  }, [chartData, totalForPeriod]);

  const maxSales = useMemo(() => {
    return Math.max(...chartData.map((d) => d.sales), 0);
  }, [chartData]);

  const CustomTooltip = ({
    active,
    payload,
    label,
  }: {
    active?: boolean;
    payload?: { value: number }[];
    label?: string;
  }) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-gray-900 rounded-lg shadow-xl p-3 border border-gray-700">
          <p className="text-xs font-medium text-gray-400 mb-1">{label}</p>
          <p className="text-lg text-white font-bold">
            {formatCurrency(payload[0].value)}
          </p>
        </div>
      );
    }
    return null;
  };

  const hasData = chartData.some((d) => d.sales > 0);

  // Get selected client name for display
  const selectedClientName = selectedClient
    ? availableClients.find(c => c.email === selectedClient)?.name
    : null;

  return (
    <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="px-6 py-4 border-b border-gray-100">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center">
              <TrendingUp className="w-5 h-5 text-indigo-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">
                Sales Overview
              </h2>
              <div className="flex items-center gap-4 mt-0.5">
                <p className="text-sm text-gray-500">
                  Total: <span className="font-semibold text-gray-900">{formatCurrency(totalForPeriod)}</span>
                </p>
                <span className="text-gray-300">|</span>
                <p className="text-sm text-gray-500">
                  Avg: <span className="font-medium text-gray-700">{formatCurrency(avgForPeriod)}</span>
                </p>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-3">
            {/* Filter Toggle Button */}
            <button
              onClick={() => setShowFilters(!showFilters)}
              className={`flex items-center gap-2 px-3 py-1.5 text-sm font-medium rounded-lg transition-colors ${
                showFilters || hasActiveFilters
                  ? "bg-indigo-100 text-indigo-700"
                  : "bg-gray-100 text-gray-600 hover:text-gray-900"
              }`}
            >
              <Filter className="w-4 h-4" />
              Filters
              {hasActiveFilters && (
                <span className="w-5 h-5 bg-indigo-600 text-white text-xs rounded-full flex items-center justify-center">
                  {(selectedYear !== null ? 1 : 0) + (selectedMonth !== null ? 1 : 0) + (selectedClient !== null ? 1 : 0)}
                </span>
              )}
            </button>

            {/* Chart Type Toggle */}
            <div className="flex items-center gap-1 bg-gray-100 rounded-lg p-1">
              <button
                onClick={() => setChartType("area")}
                className={`p-1.5 rounded-md transition-colors ${
                  chartType === "area"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-gray-700"
                }`}
                title="Area Chart"
              >
                <TrendingUp className="w-4 h-4" />
              </button>
              <button
                onClick={() => setChartType("bar")}
                className={`p-1.5 rounded-md transition-colors ${
                  chartType === "bar"
                    ? "bg-white text-indigo-600 shadow-sm"
                    : "text-gray-500 hover:text-gray-700"
                }`}
                title="Bar Chart"
              >
                <BarChart3 className="w-4 h-4" />
              </button>
            </div>

            {/* Time Period Tabs */}
            <div className="flex items-center gap-1 bg-gray-100 rounded-lg p-1">
              {timePeriods.map((period) => (
                <button
                  key={period.id}
                  onClick={() => setActivePeriod(period.id)}
                  className={`px-3 py-1.5 text-sm font-medium rounded-md transition-all ${
                    activePeriod === period.id
                      ? "bg-white text-gray-900 shadow-sm"
                      : "text-gray-600 hover:text-gray-900"
                  }`}
                >
                  {period.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Filter Panel */}
        {showFilters && (
          <div className="mt-4 pt-4 border-t border-gray-100">
            <div className="flex items-center gap-4 flex-wrap">
              {/* Year Filter */}
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-gray-400" />
                <select
                  value={selectedYear ?? ""}
                  onChange={(e) => setSelectedYear(e.target.value ? parseInt(e.target.value) : null)}
                  className="px-3 py-1.5 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                >
                  <option value="">All Years</option>
                  {availableYears.map((year) => (
                    <option key={year} value={year}>{year}</option>
                  ))}
                </select>
              </div>

              {/* Month Filter */}
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-gray-400" />
                <select
                  value={selectedMonth ?? ""}
                  onChange={(e) => setSelectedMonth(e.target.value !== "" ? parseInt(e.target.value) : null)}
                  className="px-3 py-1.5 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                >
                  <option value="">All Months</option>
                  {months.map((month) => (
                    <option key={month.value} value={month.value}>{month.label}</option>
                  ))}
                </select>
              </div>

              {/* Client Filter */}
              <div className="flex items-center gap-2">
                <User className="w-4 h-4 text-gray-400" />
                <select
                  value={selectedClient ?? ""}
                  onChange={(e) => setSelectedClient(e.target.value || null)}
                  className="px-3 py-1.5 text-sm bg-gray-50 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent min-w-[180px]"
                >
                  <option value="">All Clients</option>
                  {availableClients.map((client) => (
                    <option key={client.email} value={client.email}>{client.name}</option>
                  ))}
                </select>
              </div>

              {/* Clear Filters Button */}
              {hasActiveFilters && (
                <button
                  onClick={clearFilters}
                  className="flex items-center gap-1 px-3 py-1.5 text-sm font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors"
                >
                  <X className="w-4 h-4" />
                  Clear Filters
                </button>
              )}
            </div>

            {/* Active Filters Display */}
            {hasActiveFilters && (
              <div className="mt-3 flex items-center gap-2 flex-wrap">
                <span className="text-xs text-gray-500">Active filters:</span>
                {selectedYear !== null && (
                  <span className="inline-flex items-center gap-1 px-2 py-1 bg-indigo-50 text-indigo-700 text-xs font-medium rounded-full">
                    Year: {selectedYear}
                    <button onClick={() => setSelectedYear(null)} className="hover:text-indigo-900">
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                )}
                {selectedMonth !== null && (
                  <span className="inline-flex items-center gap-1 px-2 py-1 bg-indigo-50 text-indigo-700 text-xs font-medium rounded-full">
                    Month: {months[selectedMonth].label}
                    <button onClick={() => setSelectedMonth(null)} className="hover:text-indigo-900">
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                )}
                {selectedClient !== null && selectedClientName && (
                  <span className="inline-flex items-center gap-1 px-2 py-1 bg-indigo-50 text-indigo-700 text-xs font-medium rounded-full">
                    Client: {selectedClientName}
                    <button onClick={() => setSelectedClient(null)} className="hover:text-indigo-900">
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Chart Area */}
      <div className="p-6">
        {!hasData ? (
          <div className="h-80 flex flex-col items-center justify-center text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <TrendingUp className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-1">
              {hasActiveFilters ? "No sales data for selected filters" : "No sales data yet"}
            </h3>
            <p className="text-sm text-gray-500 max-w-xs">
              {hasActiveFilters
                ? "Try adjusting your filters to see more data."
                : "Once you start receiving payments, your sales data will appear here."}
            </p>
            {hasActiveFilters && (
              <button
                onClick={clearFilters}
                className="mt-4 px-4 py-2 text-sm font-medium text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 rounded-lg transition-colors"
              >
                Clear Filters
              </button>
            )}
          </div>
        ) : (
          <div className="h-80">
            {chartType === "area" ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart
                  data={chartData}
                  margin={{ top: 20, right: 20, left: 0, bottom: 0 }}
                >
                  <defs>
                    <linearGradient id="salesGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#6366F1" stopOpacity={0.4} />
                      <stop offset="50%" stopColor="#6366F1" stopOpacity={0.15} />
                      <stop offset="100%" stopColor="#6366F1" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid
                    strokeDasharray="3 3"
                    stroke="#E5E7EB"
                    vertical={false}
                  />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#6B7280", fontSize: 11, fontWeight: 500 }}
                    dy={10}
                    interval="preserveStartEnd"
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#6B7280", fontSize: 11, fontWeight: 500 }}
                    tickFormatter={(value) =>
                      value >= 1000 ? `$${(value / 1000).toFixed(0)}k` : `$${value}`
                    }
                    dx={-10}
                    domain={[0, maxSales * 1.1]}
                  />
                  <Tooltip
                    content={<CustomTooltip />}
                    cursor={{ stroke: "#6366F1", strokeWidth: 1, strokeDasharray: "4 4" }}
                  />
                  <Area
                    type="monotone"
                    dataKey="sales"
                    stroke="#6366F1"
                    strokeWidth={2.5}
                    fill="url(#salesGradient)"
                    dot={false}
                    activeDot={{
                      r: 6,
                      fill: "#6366F1",
                      stroke: "#fff",
                      strokeWidth: 2,
                    }}
                  />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={chartData}
                  margin={{ top: 20, right: 20, left: 0, bottom: 0 }}
                >
                  <defs>
                    <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#10B981" stopOpacity={1} />
                      <stop offset="100%" stopColor="#34D399" stopOpacity={0.8} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid
                    strokeDasharray="3 3"
                    stroke="#E5E7EB"
                    vertical={false}
                  />
                  <XAxis
                    dataKey="name"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#6B7280", fontSize: 11, fontWeight: 500 }}
                    dy={10}
                    interval="preserveStartEnd"
                  />
                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#6B7280", fontSize: 11, fontWeight: 500 }}
                    tickFormatter={(value) =>
                      value >= 1000 ? `$${(value / 1000).toFixed(0)}k` : `$${value}`
                    }
                    dx={-10}
                    domain={[0, maxSales * 1.1]}
                  />
                  <Tooltip content={<CustomTooltip />} cursor={{ fill: "rgba(16, 185, 129, 0.1)" }} />
                  <Bar
                    dataKey="sales"
                    fill="url(#barGradient)"
                    radius={[4, 4, 0, 0]}
                    maxBarSize={50}
                  />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        )}
      </div>

      {/* Summary Stats */}
      {hasData && (
        <div className="px-6 py-4 bg-gray-50 border-t border-gray-100">
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Highest</p>
              <p className="text-lg font-bold text-gray-900 mt-1">
                {formatCurrency(maxSales)}
              </p>
            </div>
            <div className="text-center border-l border-r border-gray-200">
              <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Average</p>
              <p className="text-lg font-bold text-gray-900 mt-1">
                {formatCurrency(avgForPeriod)}
              </p>
            </div>
            <div className="text-center">
              <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Periods</p>
              <p className="text-lg font-bold text-gray-900 mt-1">
                {chartData.filter(d => d.sales > 0).length} / {chartData.length}
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
