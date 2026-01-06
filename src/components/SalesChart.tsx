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
} from "recharts";
import { formatCurrency } from "@/lib/utils";

interface SalesData {
  date: string;
  amount: number;
  paidAt: string | null;
}

interface SalesChartProps {
  salesData: SalesData[];
}

type TimePeriod = "daily" | "weekly" | "monthly" | "yearly" | "all";

const timePeriods: { id: TimePeriod; label: string }[] = [
  { id: "daily", label: "Daily" },
  { id: "weekly", label: "Weekly" },
  { id: "monthly", label: "Monthly" },
  { id: "yearly", label: "Yearly" },
  { id: "all", label: "All Time" },
];

export default function SalesChart({ salesData }: SalesChartProps) {
  const [activePeriod, setActivePeriod] = useState<TimePeriod>("monthly");

  const chartData = useMemo(() => {
    const now = new Date();
    let filteredData = salesData.filter((d) => d.paidAt);
    let dataPoints: { name: string; sales: number; date: Date }[] = [];

    switch (activePeriod) {
      case "daily": {
        // Last 30 days, grouped by day
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30);

        const dailyMap = new Map<string, number>();

        // Initialize all days with 0
        for (let i = 0; i < 30; i++) {
          const date = new Date();
          date.setDate(date.getDate() - (29 - i));
          const key = date.toISOString().split("T")[0];
          dailyMap.set(key, 0);
        }

        // Fill in actual data
        filteredData.forEach((d) => {
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
        // Last 12 weeks
        const weeksMap = new Map<string, number>();

        for (let i = 0; i < 12; i++) {
          const weekStart = new Date();
          weekStart.setDate(weekStart.getDate() - (11 - i) * 7);
          const weekKey = `Week ${i + 1}`;
          weeksMap.set(weekKey, 0);
        }

        filteredData.forEach((d) => {
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
        // Last 12 months
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

        filteredData.forEach((d) => {
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
        // Last 5 years
        const yearsMap = new Map<string, number>();

        for (let i = 0; i < 5; i++) {
          const year = now.getFullYear() - (4 - i);
          yearsMap.set(year.toString(), 0);
        }

        filteredData.forEach((d) => {
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
        // Group by quarter since the beginning
        const quartersMap = new Map<string, number>();

        filteredData.forEach((d) => {
          if (!d.paidAt) return;
          const date = new Date(d.paidAt);
          const quarter = Math.floor(date.getMonth() / 3) + 1;
          const key = `Q${quarter} ${date.getFullYear()}`;
          quartersMap.set(key, (quartersMap.get(key) || 0) + d.amount);
        });

        // Sort by date
        dataPoints = Array.from(quartersMap.entries())
          .map(([key, sales]) => {
            const [q, year] = key.split(" ");
            const quarterNum = parseInt(q.replace("Q", ""));
            const date = new Date(parseInt(year), (quarterNum - 1) * 3, 1);
            return { name: key, sales, date };
          })
          .sort((a, b) => a.date.getTime() - b.date.getTime());

        // If empty, show current year quarters
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
  }, [salesData, activePeriod]);

  const totalForPeriod = useMemo(() => {
    return chartData.reduce((sum, d) => sum + d.sales, 0);
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
        <div className="bg-white border border-gray-200 rounded-lg shadow-lg p-3">
          <p className="text-sm font-medium text-gray-900">{label}</p>
          <p className="text-sm text-indigo-600 font-semibold">
            {formatCurrency(payload[0].value)}
          </p>
        </div>
      );
    }
    return null;
  };

  return (
    <div className="bg-white rounded-xl border border-gray-200 shadow-sm">
      <div className="px-6 py-4 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">
              Sales Overview
            </h2>
            <p className="text-sm text-gray-500 mt-0.5">
              Total: {formatCurrency(totalForPeriod)}
            </p>
          </div>
          <div className="flex items-center gap-1 bg-gray-100 rounded-lg p-1">
            {timePeriods.map((period) => (
              <button
                key={period.id}
                onClick={() => setActivePeriod(period.id)}
                className={`px-3 py-1.5 text-sm font-medium rounded-md transition-colors ${
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
      <div className="p-6">
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart
              data={chartData}
              margin={{ top: 10, right: 10, left: 0, bottom: 0 }}
            >
              <defs>
                <linearGradient id="salesGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#6366F1" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#6366F1" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis
                dataKey="name"
                axisLine={false}
                tickLine={false}
                tick={{ fill: "#6B7280", fontSize: 12 }}
                dy={10}
              />
              <YAxis
                axisLine={false}
                tickLine={false}
                tick={{ fill: "#6B7280", fontSize: 12 }}
                tickFormatter={(value) =>
                  value >= 1000 ? `$${(value / 1000).toFixed(0)}k` : `$${value}`
                }
                dx={-10}
              />
              <Tooltip content={<CustomTooltip />} />
              <Area
                type="monotone"
                dataKey="sales"
                stroke="#6366F1"
                strokeWidth={2}
                fill="url(#salesGradient)"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
