function kill_by_name
    set -l options '9'
    argparse $options -- $argv

    # 检查是否为中文环境
    set -lx is_chinese_env 0
    if string match -qr "zh" $LANG; or string match -qr "zh" $LC_ALL; or string match -qr "zh" $LC_MESSAGES
        set is_chinese_env 1
    end

    function print_msg
        if test $is_chinese_env -eq 1
            echo $argv[2]
        else
            echo $argv[1]
        end
    end

    if test (count $argv) -eq 0
        print_msg "Usage: kill_by_name process_name" "用法: kill_by_name 进程名"
        return 1
    end

    set process_name $argv[1]

    # 使用 ps -ef 并模糊匹配进程名
    set matches (ps -eo pid,args | grep -i --color=never $process_name | grep -v grep)

    if test (count $matches) -eq 0
        print_msg "No matching processes found." "未找到匹配的进程。"
        return 0
    end

    print_msg "Found the following processes:" "找到以下进程："
    for line in $matches
        set pid (echo $line | awk '{print $1}')
        set command (echo $line | cut -d' ' -f2-)
        echo "PID: $pid | 命令: $command"
    end

    read -P (print_msg "Kill these processes? (y/N): " "是否终止这些进程？(y/N): ") confirm

    if test "$confirm" = "y" -o "$confirm" = "Y"
        for line in $matches
            set pid (string split ' ' $line)[1]
            if set -q _flag_9
                echo "kill -9 $pid"
                kill -9 $pid
            else
                echo "kill $pid"
                kill $pid
            end
        end
    else
        print_msg "No action taken." "未执行任何操作。"
    end
end
