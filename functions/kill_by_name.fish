function kill_by_name
    set -l options '9'
    argparse $options -- $argv

    if test (count $argv) -eq 0
        echo "用法: kill_by_name 进程名"
        return 1
    end

    set process_name $argv[1]

    # 使用 ps -ef 并模糊匹配进程名
    set matches (ps -ef | grep -i --color=never $process_name | grep -v grep)

    if test (count $matches) -eq 0
        echo "未找到匹配的进程。"
        return 0
    end

    echo "找到以下进程："
    for line in $matches
        set pid (echo $line | awk '{print $2}')
        set start_time (echo $line | awk '{print $5}')
        set command (echo $line | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; sub(/^ +/, ""); print}')
        echo "PID: $pid | 启动时间: $start_time | 命令: $command"
    end

    read -P "是否终止这些进程？(y/N): " confirm

    if test "$confirm" = "y" -o "$confirm" = "Y"
        for line in $matches
            set pid (echo $line | awk '{print $2}')
            if set -q _flag_9
                echo "kill -9 $pid"
                kill -9 $pid
            else
                echo "kill $pid"
                kill $pid
            end
        end
    else
        echo "未执行任何操作。"
    end
end
